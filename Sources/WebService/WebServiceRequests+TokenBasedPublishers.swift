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
    
    func tokenBasedMethodPublisher<Result: Decodable, Decoder: TopLevelDecoder, ErrorDecoder: TopLevelDecoder>(
        endpoint:      String,
        method:        URLRequest.HTTPMethod,
        body:          Data? = nil,
        urlParameters: DictionaryRepresentable? = nil,
        contentType:   URLRequest.ContentType? = nil,
        headers:       [URLRequest.Header]? = nil,
        decoder:       Decoder,
        errorDecoder:  ErrorDecoder,
        token:         Token
    ) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {
        let request = self.request(for: endpoint, body: body, contentType: contentType, urlParameters: urlParameters, token: token, method: method, headers: headers)
        return requestPublisher(for: request, decoder: decoder, errorDecoder: errorDecoder)
    }
}
