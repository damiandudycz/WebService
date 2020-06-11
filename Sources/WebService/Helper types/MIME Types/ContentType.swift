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
        case text             (_ type: TextType = .plain, encoding: String.Encoding = .utf8)
        case application      (_ type: ApplicationType = .octetStream, encoding: String.Encoding = .utf8)
        case multipartFormData(boundary: Boundary)
        case image            (_ type: ImageType)
        
        var string: String {
            switch self {
            case let .text             (type, encoding): return "text/\(type.rawValue);charset=\(encoding.httpName)"
            case let .application      (type, encoding): return "application/\(type.rawValue);charset=\(encoding.httpName)"
            case let .multipartFormData(boundary):       return "multipart/form-data;boundary=\(boundary)"
            case let .image            (type):           return "image/\(type.rawValue)"
            }
        }
        
    }
    
}
