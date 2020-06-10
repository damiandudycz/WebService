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

public extension URLRequest {
    
    typealias Boundary = UUID

    enum Header {
        
        case contentType(_ value: ContentType)
        case authorization(_ value: String)
        
        var key: String {
            switch self {
            case .contentType:   return "Content-Type"
            case .authorization: return "Authorization"
            }
        }
        
        var value: String {
            switch self {
            case .contentType(let value): return value.string
            case .authorization(let value): return value
            }
        }
        
    }
    
    enum ContentType {
        
        case textHTML
        case applicationJSON
        case multipartFormData(boundary: Boundary)
        
        var string: String {
            switch self {
            case .textHTML: return "text/html"
            case .applicationJSON: return "application/json"
            case .multipartFormData(let boundary): return "multipart/form-data; boundary=\(boundary)"
            }
        }
        
    }
    
}
