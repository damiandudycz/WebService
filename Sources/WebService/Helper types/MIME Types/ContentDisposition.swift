//
//  File.swift
//  
//
//  Created by Home Dudycz on 12/06/2020.
//

import Foundation

public enum ContentDisposition {
    
    public typealias Boundary = URLRequest.Boundary
    
    case formData(_ data: Data, boundary: Boundary, name: String, filename: String, type: URLRequest.ContentType)
 
    func data() throws -> Data {
        
        var part = Data()
        try part.append("\r\n--\(boundary)\r\n")

        switch self {
        case let .formData(data, _, name, filename, type):
            try part.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
            try part.append("Content-Type: \(type.string)\r\n\r\n")
            part.append(data)
        }
        
        return part
        
    }
    
    var boundary: Boundary {
        switch self {
        case let .formData(_, boundary, _, _, _):
            return boundary
        }
    }
    
}
