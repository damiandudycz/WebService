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
    
    private var tokenUpdatePublisher: RequestPublisher<Token>?
    private var tokenUpdatesPromises = [(Result<Token, WebService<APIErrorType>.RequestError>) -> Void]()
    
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
        customURL:       URL? = nil,
        queryParameters: DictionaryRepresentable? = nil,
        token:           Token? = nil,
        method:          HTTPMethod = .get,
        headers:         [Header]? = nil
    ) throws -> URLRequest {
        
        let url: URL = try customURL ?? {
            guard let queryParameters = queryParameters else {
                return self.url(for: function)
            }
            let queryParametersDictionary = try queryParameters.dictionary()
            let parametersStrings = queryParametersDictionary.map { (key, value) -> String in
                "\(key)=\(value.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
            }
            let string = "?\(parametersStrings.joined(separator: "&"))"
            return self.url(for: function + string)
        }()
                
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

        // Add body
        request.httpBody = body
                
        return request
    }
    
}

// Request publishers.
public extension WebService {
        
    func requestPublisher<Result: Decodable, Decoder: ResultDecoder, ErrorDecoder: ResultDecoder>(
        for request:  URLRequest,
        decoder:      Decoder,
        errorDecoder: ErrorDecoder
    ) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {
        let randomName = UUID().uuidString
        print("New request: \(request.url!) \(randomName)")
        if let body = request.httpBody {
            print("Body:")
            if let bodyString = String(data: body, encoding: .utf8) {
                print(bodyString)
            }
            else {
                print("<BINARY DATA> \(body.count) bytes")
            }
        }
        if let headers = request.allHTTPHeaderFields {
            print("Headers:")
            print(headers)
        }
        print("---\n")
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { [self] (data, response) -> Result in

                print("Response to: \(request.url!) \(randomName)")
                let responseString = String(data: data, encoding: .utf8)!
                print(responseString)
                if let headers = request.allHTTPHeaderFields {
                    print("Request Headers:")
                    print(headers)
                }
                print("---\n")

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
                    throw requestErrorWith(error: error)
                }
            }
            .mapError { [self] in requestErrorWith(error: $0) }
            .eraseToAnyPublisher()
    }
    
    // Request publishers for Token Based API.
    /// This function will automatically obtain and store new access token if current token is expired.
    func requestPublisherWithFreshToken<Result: Decodable, Parameters>(
        _ methodCreator:     @escaping RequestPublisherWithTokenCreator<Result, Parameters>,
        parameters:          Parameters,
        token:               Token,
        tokenRefreshCreator: TokenRefreshCreator
    ) -> RequestPublisher<Result> {
        tokenVerificationPublisher(token: token, tokenRefreshCreator: tokenRefreshCreator)
            .tryMap { (_) in try methodCreator(parameters, token) }
            .mapError { [self] in requestErrorWith(error: $0) }
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }
    
}

private extension WebService {
    
    func tokenVerificationPublisher(token: Token, tokenRefreshCreator: TokenRefreshCreator) -> TokenPublisher {
        guard token.accessToken.isExpired else {
            return tokenUpdatePublisher ?? Just(token).mapError { _ in .accessTokenInvalid }.eraseToAnyPublisher()
        }
        // If token updating publisher exists connect to it, otherwise create a new one.
        guard tokenUpdatePublisher != nil else {
            // Create new publisher for token updating.
            let newTokenUpdatePublisher = tokenRefreshCreator.function(token).handleEvents(receiveOutput: { (newToken) in
                token.updateTo(newToken)
            }, receiveCompletion: { completion in
                let result: Result<Token, RequestError>
                switch completion {
                case .failure(let error):
                    result = .failure(error)
                    switch error {
                    case .wrongResponseStatus(let status) where status == .unauthorized:
                        // Sign out
                        tokenRefreshCreator.onUnathorized?()
                    default: break
                    }
                case .finished: 
                    result = .success(token)
                }
                self.tokenUpdatePublisher = nil
                self.tokenUpdatesPromises.forEach { (promise) in
                    promise(result)
                }
                self.tokenUpdatesPromises.removeAll()
            }).eraseToAnyPublisher()
            self.tokenUpdatePublisher = newTokenUpdatePublisher
            return newTokenUpdatePublisher
        }
        // Collects new requests that require token, so that all can be executed after current token update finishes.
        return Future<Token, RequestError> { [weak self] (promise) in
            self?.tokenUpdatesPromises.append(promise)
        }.eraseToAnyPublisher()
    }
    
}
