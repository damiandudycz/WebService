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
        
        // TODO: More headers
        case contentType(_ value: ContentType)
        case authorization(_ value: String)
        case contentLength(_ value: Int)
        
        var key: String {
            switch self {
            case .contentType:   return "Content-Type"
            case .authorization: return "Authorization"
            case .contentLength: return "Content-Length"
            }
        }
        
        var value: String {
            switch self {
            case .contentType(let value): return value.string
            case .authorization(let value): return value
            case .contentLength(let value): return value.description
            }
        }
        
    }
    
    enum ContentType {
        
        // TODO: More types.
        case textHTML(encoding: String.Encoding)
        case applicationJSON(encoding: String.Encoding)
        case multipartFormData(boundary: Boundary)
        
        var string: String {
            switch self {
            case .textHTML(let encoding): return "text/html;charset=\(encoding.httpName)"
            case .applicationJSON(let encoding): return "application/json;charset=\(encoding.httpName)"
            case .multipartFormData(let boundary): return "multipart/form-data;boundary=\(boundary)"
            }
        }
        
    }
    
}

extension String.Encoding {
    
    var httpName: String {
        switch self {
            // TODO: Fill this list with HTTP supported charsets.
        case .ascii: return "us-ascii"
        case .utf8:  return "utf-8"
        default: fatalError("Unsupported encoding")
        }
    }
    
}
