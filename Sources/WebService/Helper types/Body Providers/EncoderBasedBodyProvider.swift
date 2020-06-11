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
    
    public init(_ parameters: Parameters, _ encoder: Encoder) {
        self.parameters = parameters
        self.encoder = encoder
    }
    
    public func provideBody() throws -> Data? {
        try encoder.buildBody(parameters)
    }

}
