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
    
    // TODO: Different parameters for different types of data.
    // For example create an enum for Content-Disposition and make it create form fragments.
    func insert(_ data: Data, boundary: Boundary, name: String, filename: String?, type: URLRequest.ContentType, to body: inout Data) throws {
        var part = Data()
        try part.append("\r\n--\(boundary)\r\n")
        try part.append("Content-Disposition: form-data; name=\"\(name)\"")
        if let filename = filename {
            try part.append("; filename=\"\(filename)\"")
        }
        try part.append("\r\n")
        try part.append("Content-Type: \(type.string)\r\n\r\n")
        part.append(data)
        body.append(part)
    }
    
    // Finishing form
    func finishForm(_ body: inout Data, boundary: Boundary) throws {
        try body.append("\r\n--\(boundary)--\r\n")
    }
    
    func buildFormBodyForSingleData(_ data: Data, boundary: Boundary, name: String, filename: CustomStringConvertible?, type: URLRequest.ContentType) throws -> Data {
        var form = Data()
        try insert(data, boundary: boundary, name: name, filename: filename?.description, type: type, to: &form)
        try finishForm(&form, boundary: boundary)
        return form
    }

}

private extension Data {
    
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
