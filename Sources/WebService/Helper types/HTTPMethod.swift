//
//  HTTPMethod.swift
//  NetworkOperation
//
//  Created by  on 28.09.2018.
//  Copyright © 2018 . All rights reserved.
//

import Foundation

public extension URLRequest {
    
    enum HTTPMethod: String {
        // Note: Don't change the names of these cases, these are defined in REST documentation
        case get, post, put, delete, patch, head, options, copy, search
    }
    
}
