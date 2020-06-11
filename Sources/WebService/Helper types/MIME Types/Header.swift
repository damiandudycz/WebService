//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    typealias Boundary = UUID

    enum Header {
        
        // TODO: More headers
        case contentType  (_ value: ContentType)
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
            case .contentType  (let value): return value.string
            case .authorization(let value): return value
            case .contentLength(let value): return value.description
            }
        }
        
    }
    
}
