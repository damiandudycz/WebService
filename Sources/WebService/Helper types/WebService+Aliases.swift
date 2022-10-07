//
//  File.swift
//  
//
//  Created by Damian Dudycz on 09/06/2020.
//

import Foundation
import Combine

public extension WebService {
    
    typealias RequestPublisher<Result> = AnyPublisher<Result, RequestError>
    typealias TokenPublisher = RequestPublisher<TokenType>
    typealias TokenRefreshCreator = (function: (_ oldToken: TokenType) -> TokenPublisher, onDenay: (() -> Void)?)
    typealias RequestPublisherWithTokenCreator<Result> = (_ token: TokenType) throws -> RequestPublisher<Result>
}
