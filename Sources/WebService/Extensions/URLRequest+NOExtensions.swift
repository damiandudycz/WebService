//
//  URLRequest+NOExtensions.swift
//  NetworkOperation
//
//  Created by  on 19/03/2019.
//  Copyright © 2019 . All rights reserved.
//

import Foundation

extension URLRequest {
    
    var method: HTTPMethod {
        get {
            if let httpMethod = httpMethod {
                return HTTPMethod(rawValue: httpMethod.lowercased()) ?? .get
            }
            return .get
        }
        set {
            httpMethod = newValue.rawValue.uppercased()
        }
    }
}
