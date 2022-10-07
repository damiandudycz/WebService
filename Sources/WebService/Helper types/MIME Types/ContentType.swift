//
//  File.swift
//  
//
//  Created by Damian Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    enum ContentType {
        
        case multipart  (_ type: MultipartType, boundary: Boundary? = nil)
        case application(_ type: ApplicationType = .octetStream, encoding: String.Encoding = .utf8)
        case text       (_ type: TextType = .plain, encoding: String.Encoding = .utf8)
        case image      (_ type: ImageType)
        case audio      (_ type: AudioType)
        case video      (_ type: VideoType)
        case model      (_ type: ModelType)
        
        public var string: String {
            switch self {
            case let .multipart  (type, boundary):
                if let boundary = boundary {
                    return "multipart/\(type.rawValue);boundary=\(boundary)"
                }
                else {
                    return "multipart/\(type.rawValue)"
                }
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
