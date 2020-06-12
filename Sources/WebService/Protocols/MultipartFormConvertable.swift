//
//  File.swift
//  
//
//  Created by Home Dudycz on 12/06/2020.
//

import Foundation

/// A type that can convert itself into Multipart Form Data
public protocol MultipartFormConvertable {
    
    func provideFormBody(boundary: Boundary) throws -> Data
    
}

public extension MultipartFormConvertable {
        
    typealias Boundary = UUID
        
    func insert(_ content: ContentDisposition, to body: inout Data) throws {
        let contentData = try content.data()
        body.append(contentData)
    }
    
    // Finishing form
    func finishForm(_ body: inout Data, boundary: Boundary) throws {
        try body.append("\r\n--\(boundary)--\r\n")
    }
    
    func formBodyWithSingleData(_ data: Data, boundary: Boundary, name: String, filename: String, type: URLRequest.ContentType) throws -> Data {
        var body = Data()
        let content: ContentDisposition = .formData(data, boundary: boundary, name: name, filename: filename, type: type)
        try insert(content, to: &body)
        try finishForm(&body, boundary: boundary)
        return body
    }

}

// TODO: Move to Extensions/
extension Data {
    
    enum ConversionError: Error {
        case failedToConvertToData
    }
    
    mutating func append(_ string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw ConversionError.failedToConvertToData
        }
        append(data)
    }
    
}
