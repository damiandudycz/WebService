//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    enum ContentType {
        
        case multipart  (_ type: MultipartType, boundary: Boundary)
        case application(_ type: ApplicationType = .octetStream, encoding: String.Encoding = .utf8)
        case text       (_ type: TextType = .plain, encoding: String.Encoding = .utf8)
        case image      (_ type: ImageType)
        case audio      (_ type: AudioType)
        case video      (_ type: VideoType)
        case model      (_ type: ModelType)
        
        var string: String {
            switch self {
            case let .multipart  (type, boundary): return "multipart/\(type.rawValue);boundary=\(boundary)"
            case let .application(type, encoding): return "application/\(type.rawValue);charset=\(encoding.httpName)"
            case let .text       (type, encoding): return "text/\(type.rawValue);charset=\(encoding.httpName)"
            case let .image      (type):           return "image/\(type.rawValue)"
            case let .audio      (type):           return "audio/\(type.rawValue)"
            case let .video      (type):           return "video/\(type.rawValue)"
            case let .model      (type):           return "model/\(type.rawValue)"
            }
            
        }
    
    }
    
}
