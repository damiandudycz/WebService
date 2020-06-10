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
        bodyContent:   BodyParameters?, // TODO: Try remove the need for this with EmptyBodyContent.null
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        token:         Token
    ) -> RequestPublisher<Result> {
        
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, bodyContent: bodyContent, urlParameters: urlParameters, using: requestPublisher)
    }
    
}

private extension WebService {

    // MARK: - Private
    
    func createTokenBasedMethodPublisher<Result, BodyParameters: Encodable>(
        endpoint:      String,
        method:        URLRequest.HTTPMethod,
        token:         Token,
        bodyContent:   BodyParameters?,
        urlParameters: DictionaryRepresentable? = nil,
        using creator: RequestPublisherCreator<Result>
    ) -> RequestPublisher<Result> {
        
        do {
            let urlParametersDictionary = try { (_ parameters: DictionaryRepresentable?) -> [String : CustomStringConvertible]? in
                guard let parameters = parameters else { return nil }
                return try parameters.dictionary()
            }(urlParameters)
            let request = self.request(for: endpoint, bodyContent: bodyContent, urlParameters: urlParametersDictionary, token: token, method: method)
            return creator(request)
        }
        catch {
            if let error = error as? RequestError {
                return Fail(error: error).eraseToAnyPublisher()
            }
            return Fail(error: .otherError(error: error)).eraseToAnyPublisher()
        }

    }

}
