//
//  WebService.swift
//  UltronAR
//
//  Created by Home Dudycz on 02/01/2020.
//  Copyright © 2020 Damian Dudycz. All rights reserved.
//

import Foundation
import Combine
import HandyThings

open class WebService<APIErrorType: Decodable> {
    
    private let baseURL: URL
    private var cancellables = Set<AnyCancellable>()
    
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
        
    func request(
        for function:    String,
        body:            Data? = nil,
        contentType:     URLRequest.ContentType? = nil,
        queryParameters: DictionaryRepresentable? = nil,
        token:           Token? = nil,
        method:          URLRequest.HTTPMethod = .get,
        headers:         [URLRequest.Header]? = nil
    ) -> URLRequest {
        
        let url: URL = {
            if let queryParameters = queryParameters {
                // TODO: Try! handle
                let queryParametersDictionary = try! queryParameters.dictionary()
                let parametersStrings = queryParametersDictionary.map { (key, value) -> String in
                    "\(key)=\(value.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
                }
                let string = "?\(parametersStrings.joined(separator: "&"))"
                return self.url(for: function + string)
            }
            else {
                return self.url(for: function)
            }
        }()
        
        print("------------------------------")
        print("Created request: \(url)")
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.method = method
            
        // Prepare all headers
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
        
        // Add headers to request
        allHeaders.forEach { (header) in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Print headers
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }

        // Add body
        if let body = body {
            request.httpBody = body
        }
                
        return request
    }
    
}

// Request publishers.
public extension WebService {
    
    // TODO: Check if these two can be combined into one.
    
    func requestPublisher<Result: Decodable, Decoder: TopLevelDecoder, ErrorDecoder: TopLevelDecoder>(for request: URLRequest, decoder: Decoder, errorDecoder: ErrorDecoder) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {
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
                    if let requestError = error as? RequestError {
                        throw requestError
                    }
                    throw RequestError.otherError(error: error)
                }
            }
            .mapError { (error) -> RequestError in
                guard let requestError = error as? RequestError else {
                    return .otherError(error: error)
                }
                return requestError
            }
            .eraseToAnyPublisher()
    }
    
    // Request publishers for Token Based API.
    /// This function will automatically obtain and store new access token if current token is expired.
    func requestPublisherWithFreshToken<Result: Decodable, Parameters>(
        _ methodCreator:     @escaping RequestPublisherWithTokenCreator<Result, Parameters>,
        parameters:          Parameters,
        token:               Token?,
        tokenRefreshCreator: @escaping TokenRefreshCreator
    ) -> RequestPublisher<Result> {
        guard let token = token else {
            return Fail(error: .accessTokenNotAvaliable).eraseToAnyPublisher()
        }

        // Token verification checks if token needs to be updated. If it does it will create a tokenUpdatePublisher. Otherwise it will creare Just(token).
        let tokenVerification: RequestPublisher<Token> = {
            guard token.accessToken.isExpired else {
                return Just(token).mapError { _ in .accessTokenInvalid }.eraseToAnyPublisher()
            }
            // If token updating publisher exists connect to it, otherwise create a new one.
            guard let tokenUpdatePublisher = tokenUpdatePublisher else {
                // Create new publisher
                let tokenUpdatePublisher = Future<Token, RequestError> { (promise) in
                    tokenRefreshCreator(token).sink(receiveCompletion: { (completion) in
                        self.tokenUpdatePublisher = nil
                        switch completion {
                        case .finished: promise(.success(token))
                        case .failure(let error): promise(.failure(error))
                        }
                    }) { (newToken) in
                        print("Token was updated to: \(newToken.accessToken)")
                        token.updateTo(newToken)
                    }.store(in: &self.cancellables)
                }.eraseToAnyPublisher()
                self.tokenUpdatePublisher = tokenUpdatePublisher
                return tokenUpdatePublisher
            }
            return tokenUpdatePublisher.eraseToAnyPublisher()
        }()

        return tokenVerification
            .tryMap { (_) in try methodCreator(parameters, token) }
            .mapError({ (error) -> RequestError in
                if let error = error as? RequestError {
                    return error
                }
                return .otherError(error: error)
            })
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }
    
}
