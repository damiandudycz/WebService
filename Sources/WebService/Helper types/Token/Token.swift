//
//  Token.swift
//  UltronAR
//
//  Created by Home Dudycz on 01/01/2020.
//  Copyright © 2020 Damian Dudycz. All rights reserved.
//

import Foundation
import Combine

// TODO: Convert to protocol that contains accessToken and refreshToken, because these could be returned by the server with different format. Concrete WebService implementation should decide on the format, like it is with APIErrorType.
open class Token: Codable {
    
    private(set) public var accessToken: JWT
    private(set) public var refreshToken: String

    open func updateTo(_ token: Token) {
        accessToken = token.accessToken
        refreshToken = token.refreshToken
        onUpdate.send()
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
    }
        
    public let onUpdate = PassthroughSubject<Void, Never>()
    
}
