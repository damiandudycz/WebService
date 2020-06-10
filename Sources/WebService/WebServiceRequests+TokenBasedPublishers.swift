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
    
    func tokenBasedMethodPublisher<Result: Decodable>(
        endpoint:      String,
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        token:         Token
    ) -> RequestPublisher<Result> {
        
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, bodyContent: EmptyBodyContent.null, urlParameters: urlParameters, using: requestPublisher)
    }

    func tokenBasedMethodPublisher<Result: Decodable, BodyParameters: Encodable, Encoder: TopLevelEncoder>(
        endpoint:      String,
        bodyContent:   (parameters: BodyParameters, encoder: Encoder),
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        token:         Token
    ) -> RequestPublisher<Result> where Encoder.Output == Data {
        
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, bodyContent: bodyContent, urlParameters: urlParameters, using: requestPublisher)
    }
    
}

private extension WebService {

    // MARK: - Private
    
    func createTokenBasedMethodPublisher<Result, BodyParameters: Encodable, Encoder: TopLevelEncoder>(
        endpoint:      String,
        method:        URLRequest.HTTPMethod,
        token:         Token,
        bodyContent:   (parameters: BodyParameters, encoder: Encoder)?,
        urlParameters: DictionaryRepresentable? = nil,
        using creator: RequestPublisherCreator<Result>
    ) -> RequestPublisher<Result> where Encoder.Output == Data {
        
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
