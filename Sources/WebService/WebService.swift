//
//  WebService.swift
//  UltronAR
//
//  Created by Home Dudycz on 02/01/2020.
//  Copyright © 2020 Damian Dudycz. All rights reserved.
//

import Foundation
import Combine

open class WebService {
    
    public init(_ baseURL: URL) {
        self.baseURL = baseURL
    }
    
    private let baseURL: URL
    
    private var cancellables = Set<AnyCancellable>()
    
    private func url(for function: String) -> URL {
        URL(string: baseURL.absoluteString.appending("/" + function))!
    }

    // MARK: - Helper methods.
    
    /// This function will automatically obtain and store new access token if current token is expired.
    public func publisherWithFreshToken<PublisherType, ParametersType>(_ function: @escaping (_ parameters: ParametersType, _ freshToken: Token) -> AnyPublisher<PublisherType, RequestError>, tokenRefreshPublisher: @escaping (_ token: Token) -> AnyPublisher<Token, RequestError>, parameters: ParametersType) -> AnyPublisher<PublisherType, RequestError> {
        guard var usedToken = Token.currentToken else {
            return Fail(error: .accessTokenNotAvaliable).eraseToAnyPublisher()
        }
        return Future<Token, RequestError> { (promise) in
            if usedToken.accessToken.isExpired {
                print("Need new token...")
                tokenRefreshPublisher(usedToken).sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .finished: promise(.success(usedToken))
                    case .failure(let error): promise(.failure(error))
                    }
                }) { (token) in
                    usedToken = token
                    Token.currentToken = token
                }.store(in: &self.cancellables)
            }
            else {
                promise(.success(usedToken))
            }
        }
        .flatMap { (_) -> AnyPublisher<PublisherType, RequestError> in
            function(parameters, usedToken)
        }.eraseToAnyPublisher()
    }
    
    public func publisherWithFreshToken<PublisherType>(_ function: @escaping (_ parameters: EmptyRequestParameters, _ freshToken: Token) -> AnyPublisher<PublisherType, RequestError>, tokenRefreshPublisher: @escaping (_ token: Token) -> AnyPublisher<Token, RequestError>) -> AnyPublisher<PublisherType, RequestError> {
        publisherWithFreshToken(function, tokenRefreshPublisher: tokenRefreshPublisher, parameters: .empty)
    }

    // MARK: - Prepare requests.
    
    public func request(for function: String, urlParameters: [String : CustomStringConvertible]? = nil, token: Token? = nil, method: URLRequest.HTTPMethod = .get) -> URLRequest {
        
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
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.method = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    public func request<Parameters: Encodable>(for function: String, parameters: Parameters? = nil, token: Token? = nil, urlParameters: [String : CustomStringConvertible]? = nil, method: URLRequest.HTTPMethod = .get) -> URLRequest {
        var request = self.request(for: function, urlParameters: urlParameters, token: token, method: method)
        if let parameters = parameters {
            request.httpBody = try! JSONEncoder().encode(parameters)
        }
        return request
    }
    
    // MARK: - Create publishers for requests.
    
    public func requestPublisher<ResultType: Decodable>(for request: URLRequest) -> AnyPublisher<ResultType, RequestError> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ (data, response) -> ResultType in
                do {
                    return try JSONDecoder().decode(ResultType.self, from: data)
                }
                catch {
                    if let decodedErrors = try? JSONDecoder().decode(APIErrorsResponse.self, from: data) {
                        throw RequestError.apiErrors(errors: decodedErrors.errors)
                    }
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                        throw RequestError.wrongResponseCode
                    }
                    throw RequestError.otherError(error: error)
                }
            })
            .mapError({ (error) -> RequestError in
                guard let requestError = error as? RequestError else {
                    return RequestError.otherError(error: error)
                }
                return requestError
            })
            .eraseToAnyPublisher()
    }
    
    public func requestPublisherVoid(for request: URLRequest) -> AnyPublisher<Void, RequestError> {
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({ (data, response) -> Void in
                if let decodedErrors = try? JSONDecoder().decode(APIErrorsResponse.self, from: data) {
                    throw RequestError.apiErrors(errors: decodedErrors.errors)
                }
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    throw RequestError.wrongResponseCode
                }
                return ()
            })
            .mapError({ (error) -> RequestError in
                guard let requestError = error as? RequestError else {
                    return RequestError.otherError(error: error)
                }
                return requestError
            })
            .eraseToAnyPublisher()
    }

}
