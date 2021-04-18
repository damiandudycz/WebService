//
//  File.swift
//  
//
//  Created by Home Dudycz on 13/06/2020.
//

import Foundation

public struct ContentDisposition {
    
    public typealias Boundary = URLRequest.Boundary
        
    public init(header: Header, data: Data) {
        self.header = header
        self.data = data
    }
    
    let header: Header
    let data: Data
    
    func body(boundary: Boundary) throws -> Data {
        try header.data(boundary: boundary) + data
    }
    
}

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

public extension ContentDisposition.Header {
    
    enum HeaderType {
        
        case formData(name: String?, filename: String?)
        
        var string: String {
            func extractPropertyString(_ string: String?, key: String) -> String {
                guard let string = string else { return String() }
                return "; \(key)=\"" + string + "\""
            }
            switch self {
            case let .formData(name, filename):
                let nameString = extractPropertyString(name, key: "name")
                let filenameString = extractPropertyString(filename, key: "filename")
                return "form-data\(nameString)\(filenameString)"
            }
        }
        
    }

}
