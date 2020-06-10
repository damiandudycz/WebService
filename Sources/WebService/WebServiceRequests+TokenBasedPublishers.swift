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
    
    func tokenBasedMethodPublisher<Result: Decodable, BodyParameters: Encodable, Encoder: BodyEncoder, Decoder: TopLevelDecoder, ErrorDecoder: TopLevelDecoder>(
        endpoint:      String,
        bodyContent:   BodyContent<BodyParameters, Encoder>,
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        contentType:   URLRequest.ContentType? = nil,
        headers:       [URLRequest.Header]? = nil,
        decoder:       Decoder,
        errorDecoder:  ErrorDecoder,
        token:         Token
    ) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {
        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, contentType: contentType, headers: headers, token: token, bodyContent: bodyContent, decoder: decoder, errorDecoder: errorDecoder, using: requestPublisher)
    }
    
    // Simpler versions (less parameters)
    
    func tokenBasedMethodPublisher<Result: Decodable, Decoder: TopLevelDecoder, ErrorDecoder: TopLevelDecoder>(
        endpoint:      String,
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        contentType:   URLRequest.ContentType? = nil,
        headers:       [URLRequest.Header]? = nil,
        decoder:       Decoder,
        errorDecoder:  ErrorDecoder,
        token:         Token
    ) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {

        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, contentType: contentType, headers: headers, token: token, bodyContent: EmptyBodyContent.null, decoder: decoder, errorDecoder: errorDecoder, urlParameters: urlParameters, using: requestPublisher)
    }

    func tokenBasedMethodPublisher<BodyParameters: Encodable, Encoder: BodyEncoder, ErrorDecoder: TopLevelDecoder>(
        endpoint:      String,
        bodyContent:   BodyContent<BodyParameters, Encoder>,
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        contentType:   URLRequest.ContentType? = nil,
        headers:       [URLRequest.Header]? = nil,
        errorDecoder:  ErrorDecoder,
        token:         Token
    ) -> RequestPublisher<EmptyRequestResult> where ErrorDecoder.Input == Data {

        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, contentType: contentType, headers: headers, token: token, bodyContent: bodyContent, decoder: EmptyRequestResultDecoder.empty, errorDecoder: errorDecoder, urlParameters: urlParameters, using: requestPublisher)
    }

    func tokenBasedMethodPublisher<ErrorDecoder: TopLevelDecoder>(
        endpoint:      String,
        urlParameters: DictionaryRepresentable? = nil,
        method:        URLRequest.HTTPMethod,
        contentType:   URLRequest.ContentType? = nil,
        headers:       [URLRequest.Header]? = nil,
        errorDecoder:  ErrorDecoder,
        token:         Token
    ) -> RequestPublisher<EmptyRequestResult> where ErrorDecoder.Input == Data {

        createTokenBasedMethodPublisher(endpoint: endpoint, method: method, contentType: contentType, headers: headers, token: token, bodyContent: EmptyBodyContent.null, decoder: EmptyRequestResultDecoder.empty, errorDecoder: errorDecoder, urlParameters: urlParameters, using: requestPublisher)
    }

}

private extension WebService {

    // MARK: - Private
    
    func createTokenBasedMethodPublisher<Result, BodyParameters: Encodable, Encoder: BodyEncoder, Decoder: TopLevelDecoder, ErrorDecoder: TopLevelDecoder>(
        endpoint:      String,
        method:        URLRequest.HTTPMethod,
        contentType:   URLRequest.ContentType? = nil,
        headers:       [URLRequest.Header]? = nil,
        token:         Token,
        bodyContent:   BodyContent<BodyParameters, Encoder>?,
        decoder:       Decoder,
        errorDecoder:  ErrorDecoder,
        urlParameters: DictionaryRepresentable? = nil,
        using creator: RequestPublisherCreator<Result, Decoder, ErrorDecoder>
    ) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {
        
        do {
            let urlParametersDictionary = try { (_ parameters: DictionaryRepresentable?) -> [String : CustomStringConvertible]? in
                guard let parameters = parameters else { return nil }
                return try parameters.dictionary()
            }(urlParameters)
            let request = self.request(for: endpoint, bodyContent: bodyContent, contentType: contentType, urlParameters: urlParametersDictionary, token: token, method: method, headers: headers)
            return creator(request, decoder, errorDecoder)
        }
        catch {
            if let error = error as? RequestError {
                return Fail(error: error).eraseToAnyPublisher()
            }
            return Fail(error: .otherError(error: error)).eraseToAnyPublisher()
        }

    }

}
