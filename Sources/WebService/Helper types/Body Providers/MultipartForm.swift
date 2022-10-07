//
//  File.swift
//  
//
//  Created by Damian Dudycz on 11/06/2020.
//

import Foundation

public class MultipartForm: BodyProvider {
    
    public typealias Boundary = URLRequest.Boundary
    
    let boundary: Boundary
    let parts: [ContentDispositionConvertable]
    
    public init(boundary: Boundary, parts: [ContentDispositionConvertable]) {
        self.boundary = boundary
        self.parts = parts
    }
    
    public func provideBody() throws -> Data {
        var body = Data()

        // Append all content parts.
        let bodyParts = try parts.map { try $0.contentDisposition().body(boundary: boundary) }
        bodyParts.forEach { body.append($0) }
        
        // Finish form
        try body.append("--\(boundary)--\r\n")
                        
        return body
    }

}
