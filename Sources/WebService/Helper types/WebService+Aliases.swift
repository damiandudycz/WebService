//
//  File.swift
//  
//
//  Created by Home Dudycz on 09/06/2020.
//

import Foundation
import Combine

public extension WebService {
    
    typealias RequestPublisher<Type> = AnyPublisher<Type, RequestError>
    typealias TokenPublisher = RequestPublisher<Token>
    typealias TokenRefreshCreator = (_ token: Token) -> TokenPublisher
    typealias FreshTokenBasedMethodCreator<PublisherType, ParametersType> = (_ parameters: ParametersType, _ freshToken: Token) -> RequestPublisher<PublisherType>
    typealias RequestPublisherCreator<Result, Decoder: TopLevelDecoder, ErrorDecoder: TopLevelDecoder> = (_ request: URLRequest, _ decoder: Decoder, _ errorDecoder: ErrorDecoder) -> RequestPublisher<Result>
    
}
