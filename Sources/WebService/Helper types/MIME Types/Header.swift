//
//  File.swift
//  
//
//  Created by Damian Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    typealias Boundary = UUID

    enum Header {
        
        // Note: This list is not full. Add more if needed.
        // Reference: https://en.wikipedia.org/wiki/List_of_HTTP_header_fields
        
        case accept       (_ value: ContentType)
        case acceptCharset(_ value: String.Encoding)
        case authorization(_ value: String)
        case contentType  (_ value: ContentType)
        case contentLength(_ value: Int)
        case contentMD5   (_ value: String)
        case userAgent    (_ value: String)
        case custom       (name: String, value: String)

        public var key: String {
            switch self {
            case .accept:        return "Accept"
            case .acceptCharset: return "Accept-Charset"
            case .authorization: return "Authorization"
            case .contentType:   return "Content-Type"
            case .contentLength: return "Content-Length"
            case .contentMD5:    return "Content-MD5"
            case .userAgent:     return "User-Agent"
            case .custom(let name, _): return name
            }
        }
        
        public var value: String {
            switch self {
            case .accept       (let value): return value.string
            case .acceptCharset(let value): return value.httpName
            case .authorization(let value): return value
            case .contentType  (let value): return value.string
            case .contentLength(let value): return value.description
            case .contentMD5   (let value): return value
            case .userAgent    (let value): return value
            case .custom(_, let name): return name
            }
        }
        
    }
    
}
