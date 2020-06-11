//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public struct MultipartForm<Parameters>: BodyContentMaker {
    
    public func prepareBody() throws -> Data? {
        try encoder.buildBody(parameters)
    }
    
    public init(_ parameters: Parameters, boundary: URLRequest.Boundary) {
        self.parameters = parameters
        self.encoder = MultipartFormEncoder(boundary: boundary)
    }
    
    public let parameters: Parameters
    public let encoder: MultipartFormEncoder
    
}
