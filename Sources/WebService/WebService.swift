//
//  WebService.swift
//  UltronAR
//
//  Created by Home Dudycz on 02/01/2020.
//  Copyright © 2020 Damian Dudycz. All rights reserved.
//

import Foundation
import Combine

// TODO: Generics for JSONDecoder() and JSONEncoder()

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
        
    func request<Parameters: Encodable>(
        for function:  String,
        bodyContent:   Parameters?,
        urlParameters: [String : CustomStringConvertible]? = nil,
        token:         Token? = nil,
        method:        URLRequest.HTTPMethod = .get
    ) -> URLRequest {
        
        let url: URL = {
            if let urlParameters = urlParameters {
                let parametersStrings = urlParameters.map { (key, value) -> String in
                    "\(key)=\(value.description.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"
                }
                let string = "?\(parametersStrings.joined(separator: "&"))"
                return self.url(for: function + string)
            }
            else {
                return self.url(for: function)
            }
        }()
        
        print("Created request: \(url)")
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.method = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        if let bodyContent = bodyContent {
            request.httpBody = try! JSONEncoder().encode(bodyContent)
        }
        return request
    }

}

// Request publishers.
public extension WebService {
    
    func requestPublisher<ResultType: Decodable>(for request: URLRequest) -> RequestPublisher<ResultType> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ (data, response) -> ResultType in
                do {
                    return try JSONDecoder().decode(ResultType.self, from: data)
                }
                catch {
                    if let decodedError = try? JSONDecoder().decode(APIErrorType.self, from: data) {
                        throw RequestError.apiError(error: decodedError, response: response)
                    }
                    guard let response = response as? HTTPURLResponse else {
                        throw RequestError.failedToReadResponse
                    }
                    let statusCode = response.statusCode
                    guard statusCode == 200 else {
                        throw RequestError.wrongResponseCode(code: statusCode)
                    }
                    throw RequestError.otherError(error: error)
                }
            })
            .mapError({ (error) -> RequestError in
                guard let requestError = error as? RequestError else {
                    return .otherError(error: error)
                }
                return requestError
            })
            .eraseToAnyPublisher()
    }
    
    func requestPublisherVoid(for request: URLRequest) -> RequestPublisher<Void> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ (data, response) -> Void in
                if let decodedError = try? JSONDecoder().decode(APIErrorType.self, from: data) {
                    throw RequestError.apiError(error: decodedError, response: response)
                }
                guard let response = response as? HTTPURLResponse else {
                    throw RequestError.failedToReadResponse
                }
                let statusCode = response.statusCode
                guard statusCode == 200 else {
                    throw RequestError.wrongResponseCode(code: statusCode)
                }
                return ()
            })
            .mapError({ (error) -> RequestError in
                guard let requestError = error as? RequestError else {
                    return .otherError(error: error)
                }
                return requestError
            })
            .eraseToAnyPublisher()
    }
    
}

// Request publishers for Token Based API.
public extension WebService {
    
    /// This function will automatically obtain and store new access token if current token is expired.
    func publisherWithFreshToken<PublisherType, ParametersType>(
        _ methodCreator:     @escaping FreshTokenBasedMethodCreator<PublisherType, ParametersType>,
        parameters:          ParametersType,
        token:               Token?,
        tokenRefreshCreator: @escaping TokenRefreshCreator
    ) -> RequestPublisher<PublisherType> {
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
        
        return tokenVerification.flatMap { (_) in methodCreator(parameters, token) }.eraseToAnyPublisher()
    }
        
}
