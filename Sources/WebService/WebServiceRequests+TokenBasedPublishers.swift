//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation
import Combine

extension WebService {
    
    public func tokenBasedMethodPublisher<Result: Decodable, BodyParameters: Encodable>(endpoint: String, method: URLRequest.HTTPMethod, token: Token, parameters: BodyParameters?, urlParameters: DictionaryRepresentable? = nil) -> AnyPublisher<Result, RequestError> {
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, parameters: parameters, urlParameters: urlParameters, using: requestPublisher)
    }
    
    public func tokenBasedMethodVoidPublisher<BodyParameters: Encodable>(endpoint: String, method: URLRequest.HTTPMethod, token: Token, parameters: BodyParameters?, urlParameters: DictionaryRepresentable? = nil) -> AnyPublisher<Void, RequestError> {
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, parameters: parameters, urlParameters: urlParameters, using: requestPublisherVoid)
    }
    
    private func createTokenBasedMethodPublisher<Result, BodyParameters: Encodable>(endpoint: String, method: URLRequest.HTTPMethod, token: Token, parameters: BodyParameters?, urlParameters: DictionaryRepresentable? = nil, using creator: (_ request: URLRequest) -> AnyPublisher<Result, RequestError>) -> AnyPublisher<Result, RequestError> {
        do {
            let urlParametersDictionary = try { (_ parameters: DictionaryRepresentable?) -> [String : CustomStringConvertible]? in
                guard let parameters = parameters else { return nil }
                return try parameters.dictionary()
            }(urlParameters)
            let request = self.request(for: endpoint, parameters: parameters, token: token, urlParameters: urlParametersDictionary, method: method)
            return creator(request)
        }
        catch {
            if let error = error as? RequestError { return Fail<Result, RequestError>(error: error).eraseToAnyPublisher() }
            return Fail<Result, RequestError>(error: .otherError(error: error)).eraseToAnyPublisher()
        }

    }
    
}
