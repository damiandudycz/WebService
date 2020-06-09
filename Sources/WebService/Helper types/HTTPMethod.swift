//
//  HTTPMethod.swift
//  NetworkOperation
//
//  Created by Damian Dudycz on 28.09.2018.
//  Copyright © 2018 Damian Dudycz. All rights reserved.
//

import Foundation

public extension URLRequest {
    
    enum HTTPMethod: String {
        // Dont change names of these cases, these are defined in REST documentation
        case get, post, put, delete, patch, head, options, copy, search
    }
    
}
