//
//  Token.swift
//  UltronAR
//
//  Created by Home Dudycz on 01/01/2020.
//  Copyright © 2020 Damian Dudycz. All rights reserved.
//

import Foundation

// TODO: Convert to protocol that contains accessToken and refreshToken, because these could be returned by the server with different format. Concrete WebService implementation should decide on the format, like it is with APIErrorType.
open class Token: Codable {
    
    private(set) var accessToken: JWT
    private(set) var refreshToken: String

    open func updateTo(_ token: Token) {
        self.accessToken = token.accessToken
        self.refreshToken = token.refreshToken
    }
    
}
