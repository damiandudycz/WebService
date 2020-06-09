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
    
    private let baseURL: URL
    private var cancellables = Set<AnyCancellable>()
    
    public init(_ baseURL: URL) {
        self.baseURL = baseURL
    }
    
}

private extension WebService {

    func url(for function: String) -> URL {
        URL(string: baseURL.absoluteString.appending("/" + function))!
    }

}

// Requests.
public extension WebService {
    
    func request(
        for function:  String,
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
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.method = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func request<Parameters: Encodable>(
        for function:  String,
        parameters:    Parameters? = nil,
        token:         Token? = nil,
        urlParameters: [String : CustomStringConvertible]? = nil,
        method:        URLRequest.HTTPMethod = .get
    ) -> URLRequest {
        
        var request = self.request(for: function, urlParameters: urlParameters, token: token, method: method)
        if let parameters = parameters {
            request.httpBody = try! JSONEncoder().encode(parameters)
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
    
    func requestPublisherVoid(for request: URLRequest) -> RequestPublisher<Void> {
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

// Request publishers for Token Based API.
public extension WebService {
    
    /// This function will automatically obtain and store new access token if current token is expired.
    func publisherWithFreshToken<PublisherType, ParametersType>(
        _ function:            @escaping FreshTokenBasedMethodCreator<PublisherType, ParametersType>,
        tokenRefreshPublisher: @escaping TokenRefreshCreator,
        token:                 Token?,
        parameters:            ParametersType
    ) -> RequestPublisher<PublisherType> {
        guard let token = token else {
            return Fail(error: .accessTokenNotAvaliable).eraseToAnyPublisher()
        }
        return Future<Token, RequestError> { (promise) in
            if token.accessToken.isExpired {
                print("Need new token...")
                tokenRefreshPublisher(token).sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .finished: promise(.success(token))
                    case .failure(let error): promise(.failure(error))
                    }
                }) { (newToken) in
                    token.updateTo(newToken)
                }.store(in: &self.cancellables)
            }
            else {
                promise(.success(token))
            }
        }
        .flatMap { (_) -> AnyPublisher<PublisherType, RequestError> in
            function(parameters, token)
        }.eraseToAnyPublisher()
    }
    
    func publisherWithFreshToken<PublisherType>(
        _ function:            @escaping FreshTokenBasedMethodCreator<PublisherType, EmptyRequestParameters>,
        token:                 Token?,
        tokenRefreshPublisher: @escaping TokenRefreshCreator
    ) -> RequestPublisher<PublisherType> {
        publisherWithFreshToken(function, tokenRefreshPublisher: tokenRefreshPublisher, token: token, parameters: .empty)
    }
    
}
