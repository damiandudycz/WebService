//
//  Token.swift
//  UltronAR
//
//  Created by Home Dudycz on 01/01/2020.
//  Copyright © 2020 Damian Dudycz. All rights reserved.
//

import Foundation

public class Token: Codable {
    
    let accessToken: JWT
    let refreshToken: String

}

public extension Token {
    
    // TODO: Storing token in safe way.

    static var currentToken: Token? = {
        guard let tokenData = UserDefaults.standard.data(forKey: "token") else { return nil }
        return try? JSONDecoder().decode(Token.self, from: tokenData)
    }() {
        didSet {
            if let currentToken = currentToken {
                if let data = try? JSONEncoder().encode(currentToken) {
                    UserDefaults.standard.setValue(data, forKeyPath: "token")
                }
            }
            else {
                UserDefaults.standard.removeObject(forKey: "token")
            }
        }
    }
    
}
