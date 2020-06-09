//
//  Token.swift
//  UltronAR
//
//  Created by Home Dudycz on 01/01/2020.
//  Copyright © 2020 Damian Dudycz. All rights reserved.
//

import Foundation

open class Token: Codable {
    
    private(set) var accessToken: JWT
    private(set) var refreshToken: String

    open func updateTo(_ token: Token) {
        self.accessToken = token.accessToken
        self.refreshToken = token.refreshToken
    }
    
}
