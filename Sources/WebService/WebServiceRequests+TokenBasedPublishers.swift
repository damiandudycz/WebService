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
    
    func tokenBasedMethodPublisher<Result: Decodable, BodyParameters: Encodable, Encoder: TopLevelEncoder, Decoder: TopLevelDecoder>(
        endpoint:      String,
        bodyContent:   (parameters: BodyParameters, encoder: Encoder),
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        decoder:       Decoder,
        token:         Token
    ) -> RequestPublisher<Result> where Encoder.Output == Data, Decoder.Input == Data {
        
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, bodyContent: bodyContent, decoder: decoder, urlParameters: urlParameters, using: requestPublisher)
    }
    
    // Simpler versions (less parameters)
    
    func tokenBasedMethodPublisher<Result: Decodable, Decoder: TopLevelDecoder>(
        endpoint:      String,
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        decoder:       Decoder,
        token:         Token
    ) -> RequestPublisher<Result> where Decoder.Input == Data {
        
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, bodyContent: EmptyBodyContent.null, decoder: decoder, urlParameters: urlParameters, using: requestPublisher)
    }
    
    func tokenBasedMethodPublisher<BodyParameters: Encodable, Encoder: TopLevelEncoder>(
        endpoint:      String,
        bodyContent:   (parameters: BodyParameters, encoder: Encoder),
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        token:         Token
    ) -> RequestPublisher<EmptyRequestResult> where Encoder.Output == Data {
        
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, bodyContent: bodyContent, decoder: EmptyRequestResultDecoder.empty, urlParameters: urlParameters, using: requestPublisher)
    }

    func tokenBasedMethodPublisher(
        endpoint:      String,
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        token:         Token
    ) -> RequestPublisher<EmptyRequestResult> {
        
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, token: token, bodyContent: EmptyBodyContent.null, decoder: EmptyRequestResultDecoder.empty, urlParameters: urlParameters, using: requestPublisher)
    }

}

private extension WebService {

    // MARK: - Private
    
    func createTokenBasedMethodPublisher<Result, BodyParameters: Encodable, Encoder: TopLevelEncoder, Decoder: TopLevelDecoder>(
        endpoint:      String,
        method:        URLRequest.HTTPMethod,
        token:         Token,
        bodyContent:   (parameters: BodyParameters, encoder: Encoder)?,
        decoder:       Decoder,
        urlParameters: DictionaryRepresentable? = nil,
        using creator: RequestPublisherCreator<Result, Decoder>
    ) -> RequestPublisher<Result> where Encoder.Output == Data, Decoder.Input == Data {
        
        do {
            let urlParametersDictionary = try { (_ parameters: DictionaryRepresentable?) -> [String : CustomStringConvertible]? in
                guard let parameters = parameters else { return nil }
                return try parameters.dictionary()
            }(urlParameters)
            let request = self.request(for: endpoint, bodyContent: bodyContent, urlParameters: urlParametersDictionary, token: token, method: method)
            return creator(request, decoder)
        }
        catch {
            if let error = error as? RequestError {
                return Fail(error: error).eraseToAnyPublisher()
            }
            return Fail(error: .otherError(error: error)).eraseToAnyPublisher()
        }

    }

}
