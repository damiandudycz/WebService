//
//  WebService.swift
//  UltronAR
//
//  Created by Home Dudycz on 02/01/2020.
//  Copyright © 2020 Damian Dudycz. All rights reserved.
//

// TODO: Check Error enums, if they are in correct places and are not redundant.

import Foundation
import Combine
import HandyThings

open class WebService<APIErrorType: Decodable> {
    
    public let baseURL: URL
    
    public init(_ baseURL: URL) {
        self.baseURL = baseURL
    }
    
    fileprivate var tokenUpdatePublisher: RequestPublisher<Token>?
    
}

private extension WebService {

    func url(for function: String) -> URL {
        URL(string: baseURL.absoluteString.appending("/" + function))!
    }

}

// Requests.
public extension WebService {
    
    typealias ContentType = URLRequest.ContentType
    typealias HTTPMethod  = URLRequest.HTTPMethod
    typealias Header      = URLRequest.Header

    func request(
        for function:    String,
        body:            Data? = nil,
        contentType:     ContentType? = nil,
        queryParameters: DictionaryRepresentable? = nil,
        token:           Token? = nil,
        method:          HTTPMethod = .get,
        headers:         [Header]? = nil
    ) throws -> URLRequest {
        
        let url: URL = try {
            guard let queryParameters = queryParameters else {
                return self.url(for: function)
            }
            // TODO: Try! handle
            let queryParametersDictionary = try queryParameters.dictionary()
            let parametersStrings = queryParametersDictionary.map { (key, value) -> String in
                "\(key)=\(value.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
            }
            let string = "?\(parametersStrings.joined(separator: "&"))"
            return self.url(for: function + string)
        }()
        
        print("------------------------------")
        print("Created request: \(url)")
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.method = method
            
        // Prepare all headers
        let allHeaders: [Header] = {
            var allHeaders = headers ?? []
            
            if let contentType = contentType {
                allHeaders.append(.contentType(contentType))
            }
            if let token = token {
                allHeaders.append(.authorization("Bearer \(token.accessToken)"))
            }
            if let body = body {
                allHeaders.append(.contentLength(body.count))
            }
            return allHeaders
        }()
        
        // Add headers to request
        allHeaders.forEach { (header) in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Print headers
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }

        // Add body
        request.httpBody = body
                
        return request
    }
    
}

// Request publishers.
public extension WebService {
    
    // TODO: Check if these two can be combined into one.
    
    func requestPublisher<Result: Decodable, Decoder: ResultDecoder, ErrorDecoder: ResultDecoder>(
        for request:  URLRequest,
        decoder:      Decoder,
        errorDecoder: ErrorDecoder
    ) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Result in
                do {
                    guard let response = response as? HTTPURLResponse else {
                        throw RequestError.failedToReadResponse
                    }
                    let status = response.status
                    guard status.isSuccess else {
                        throw RequestError.wrongResponseStatus(status: status)
                    }
                    return try decoder.decode(Result.self, from: data)
                }
                catch {
                    if let decodedError = try? errorDecoder.decode(APIErrorType.self, from: data) {
                        throw RequestError.apiError(error: decodedError, response: response)
                    }
                    throw self.requestErrorWith(error: error)
                }
            }
            .mapError { self.requestErrorWith(error: $0) }
            .eraseToAnyPublisher()
    }
    
    // Request publishers for Token Based API.
    /// This function will automatically obtain and store new access token if current token is expired.
    func requestPublisherWithFreshToken<Result: Decodable, Parameters>(
        _ methodCreator:     @escaping RequestPublisherWithTokenCreator<Result, Parameters>,
        parameters:          Parameters,
        token:               Token,
        tokenRefreshCreator: @escaping TokenRefreshCreator
    ) -> RequestPublisher<Result> {

        return tokenVerificationPublisher(token: token, tokenRefreshCreator: tokenRefreshCreator)
            .tryMap { (_) in try methodCreator(parameters, token) }
            .mapError { self.requestErrorWith(error: $0) }
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }
    
}

private extension WebService {
    
    func tokenVerificationPublisher(token: Token, tokenRefreshCreator: @escaping TokenRefreshCreator) -> TokenPublisher {
        guard token.accessToken.isExpired else {
            return tokenUpdatePublisher ?? Just(token).mapError { _ in .accessTokenInvalid }.eraseToAnyPublisher()
        }
        // If token updating publisher exists connect to it, otherwise create a new one.
        guard let tokenUpdatePublisher = tokenUpdatePublisher else {
            // Create new publisher for token updating.
            let newTokenUpdatePublisher = tokenRefreshCreator(token).handleEvents(receiveOutput: { (newToken) in
                print("Token was updated to: \(newToken.accessToken)")
                token.updateTo(newToken)
            }, receiveCompletion: { (_) in
                self.tokenUpdatePublisher = nil
            }).eraseToAnyPublisher()
            self.tokenUpdatePublisher = newTokenUpdatePublisher
            return newTokenUpdatePublisher
        }
        // Return existing token update publisher.
        return tokenUpdatePublisher.eraseToAnyPublisher()
    }

}
