//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public struct MultipartFormBodyProvider<Parameters>: BodyProvider {
    
    public func provideBody() throws -> Data? {
        try encoder.buildBody(parameters)
    }
    
    public init(_ parameters: Parameters, boundary: URLRequest.Boundary) {
        self.parameters = parameters
        self.encoder = MultipartFormBodyEncoder(boundary: boundary)
    }
    
    public let parameters: Parameters
    public let encoder: MultipartFormBodyEncoder
    
}
