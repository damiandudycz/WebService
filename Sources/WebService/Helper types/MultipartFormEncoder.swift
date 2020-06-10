//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation

public struct MultipartFormEncoder: BodyEncoder {
    
    public typealias Boundary = URLRequest.Boundary
    
    private let boundary: Boundary
    
    public init(boundary: Boundary) {
        self.boundary = boundary
    }
    
    public func buildBody<Parameters>(_ parameters: Parameters) throws -> Data where Parameters : Encodable {
        var data = Data()
        if let parameters = parameters as? Data {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(parameters)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        }
        return data
    }
    
}
