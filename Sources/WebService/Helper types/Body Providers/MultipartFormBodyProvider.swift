//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public struct MultipartFormBodyProvider<Parameters>: BodyProvider {
    
    public func provideBody() throws -> Data {
        try encoder.encodeBody(parameters)
    }
    
    public init(boundary: URLRequest.Boundary, parameters: Parameters) {
        self.encoder = MultipartFormBodyEncoder(boundary: boundary)
        self.parameters = parameters
    }
    
    public let parameters: Parameters
    public let encoder: MultipartFormBodyEncoder
    
}
