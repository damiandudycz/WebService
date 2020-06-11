//
//  File.swift
//  
//
//  Created by Home Dudycz on 09/06/2020.
//

import Foundation
import Combine

public extension WebService {
    
    typealias RequestPublisher<Result> = AnyPublisher<Result, RequestError>
    typealias TokenPublisher = RequestPublisher<Token>
    typealias TokenRefreshCreator = (_ token: Token) -> TokenPublisher
    typealias FreshTokenBasedMethodCreator<Result, Parameters> = (_ parameters: Parameters, _ freshToken: Token) throws -> RequestPublisher<Result>
    
}
