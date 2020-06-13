//
//  File.swift
//  
//
//  Created by Home Dudycz on 13/06/2020.
//

import Foundation

public extension ContentDisposition {
    
    struct Header {
        
        public typealias Boundary = URLRequest.Boundary
        
        let contentDispositionType: HeaderType
        
        func data(boundary: Boundary) throws -> Data {
            guard let data = string(boundary: boundary).data(using: .utf8) else {
                throw ContentDispositionConversionError.failedToConvertHeaderToData
            }
            return data
        }
        
        private func string(boundary: Boundary) -> String {
            return "--\(boundary)\r\nContent-Disposition: \(contentDispositionType.string)\r\n\r\n"
        }
        
    }
    
}
