//
//  File.swift
//  
//
//  Created by Damian Dudycz on 13/06/2020.
//

import Foundation

public extension ContentDisposition {
    
    struct Header {
        
        public typealias Boundary = URLRequest.Boundary
        public typealias ContentType = URLRequest.ContentType

        let contentDispositionType: HeaderType
        let contentType: ContentType?
        
        func data(boundary: Boundary) throws -> Data {
            guard let data = string(boundary: boundary).data(using: .utf8) else {
                throw ContentDispositionConversionError.failedToConvertHeaderToData
            }
            return data
        }
        
        private func string(boundary: Boundary) -> String {
            if let contentType = contentType {
                return "--\(boundary)\r\nContent-Disposition: \(contentDispositionType.string)\r\nContent-Type: \(contentType.string)\r\n\r\n"
            }
            return "--\(boundary)\r\nContent-Disposition: \(contentDispositionType.string)\r\n\r\n"
        }
        
    }
    
}
