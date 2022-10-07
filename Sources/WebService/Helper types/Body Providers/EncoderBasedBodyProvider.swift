//
//  File.swift
//  
//
//  Created by Damian Dudycz on 10/06/2020.
//

import Foundation
import Combine

public class EncoderBasedBodyProvider<Encoder: TopLevelEncoder, Parameters: Encodable>: BodyProvider where Encoder.Output == Data {
        
    let encoder: Encoder
    let parameters: Parameters
    
    public init(encoder: Encoder, parameters: Parameters) {
        self.encoder = encoder
        self.parameters = parameters
    }
    
    public func provideBody() throws -> Data {
        try encoder.encode(parameters)
    }
    
}
