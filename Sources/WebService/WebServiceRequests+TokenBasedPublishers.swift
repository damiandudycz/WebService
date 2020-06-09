//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation
import Combine
import HandyThings

public extension WebService {
    
    // MARK: - Public
    
    func tokenBasedMethodPublisher<Result: Decodable, BodyParameters: Encodable>(
        endpoint:      String,
        parameters:    BodyParameters?,
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        token:         Token
    ) -> RequestPublisher<Result> {
        
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, parameters: parameters, urlParameters: urlParameters, using: requestPublisher)
    }
    
    func tokenBasedMethodVoidPublisher<BodyParameters: Encodable>(
        endpoint:      String,
        parameters:    BodyParameters?,
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        token:         Token
    ) -> RequestPublisher<Void> {
        
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, parameters: parameters, urlParameters: urlParameters, using: requestPublisherVoid)
    }
        
}

private extension WebService {

    // MARK: - Private
    
    func createTokenBasedMethodPublisher<Result, BodyParameters: Encodable>(
        endpoint:      String,
        method:        URLRequest.HTTPMethod,
        token:         Token,
        parameters:    BodyParameters?,
        urlParameters: DictionaryRepresentable? = nil,
        using creator: RequestPublisherCreator<Result>
    ) -> RequestPublisher<Result> {
        
        do {
            let urlParametersDictionary = try { (_ parameters: DictionaryRepresentable?) -> [String : CustomStringConvertible]? in
                guard let parameters = parameters else { return nil }
                return try parameters.dictionary()
            }(urlParameters)
            let request = self.request(for: endpoint, parameters: parameters, token: token, urlParameters: urlParametersDictionary, method: method)
            return creator(request)
        }
        catch {
            if let error = error as? RequestError {
                return Fail<Result, RequestError>(error: error).eraseToAnyPublisher()
            }
            return Fail<Result, RequestError>(error: .otherError(error: error)).eraseToAnyPublisher()
        }

    }

}
