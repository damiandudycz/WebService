//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation

public struct EncoderBasedBodyProvider<Parameters: Encodable, Encoder: BodyEncoder>: BodyProvider {
    
    public let parameters: Parameters
    public let encoder:    Encoder
    
    public init(encoder: Encoder, parameters: Parameters) {
        self.encoder = encoder
        self.parameters = parameters
    }
    
    public func provideBody() throws -> Data {
        try encoder.encodeBody(parameters)
    }

}
