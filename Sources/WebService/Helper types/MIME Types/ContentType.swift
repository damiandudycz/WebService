//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    enum ContentType {
        
        // TODO: More types.
        // TODO: Split application like image into container
        case textHTML         (encoding: String.Encoding = .utf8)
        case textPlain
        case applicationJSON  (encoding: String.Encoding = .utf8)
        case applicationOctetStream
        case multipartFormData(boundary: Boundary)
        case image(_ type: ImageType)
        
        var string: String {
            switch self {
            case .textHTML         (let encoding): return "text/html;charset=\(encoding.httpName)"
            case .textPlain:                       return "text/plain"
            case .applicationJSON  (let encoding): return "application/json;charset=\(encoding.httpName)"
            case .applicationOctetStream:          return "application/octet-stream"
            case .multipartFormData(let boundary): return "multipart/form-data;boundary=\(boundary)"
            case .image            (let type):     return "image/\(type.rawValue)"
            }
        }
        
    }
    
}
