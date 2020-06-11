//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation

public struct ParametersEncoder<Parameters: Encodable, Encoder: BodyEncoder>: BodyContentMaker {
    
    public let parameters: Parameters
    public let encoder:    Encoder
    
    public init(_ parameters: Parameters, _ encoder: Encoder) {
        self.parameters = parameters
        self.encoder = encoder
    }
    
    public func prepareBody() throws -> Data? {
        try encoder.buildBody(parameters)
    }

}