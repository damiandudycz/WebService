//
//  URLRequest+NOExtensions.swift
//  NetworkOperation
//
//  Created by Damian Dudycz on 19/03/2019.
//  Copyright © 2019 Damian Dudycz. All rights reserved.
//

import Foundation

extension URLRequest {
    
    var method: HTTPMethod {
        get {
            if let httpMethod = httpMethod {
                return HTTPMethod(rawValue: httpMethod) ?? .get
            }
            return .get
        }
        set {
            httpMethod = newValue.rawValue
        }
    }
    
}
