//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation

public protocol BodyContentMaker {
    func prepareBody() throws -> Data?
}

public struct BodyContent<Parameters: Encodable, Encoder: BodyEncoder>: BodyContentMaker {
    
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
//
//public struct BodyForm: BodyContentMaker {
//    
//    public func prepareBody() throws -> Data? {
//        
//    }
//    
//}
