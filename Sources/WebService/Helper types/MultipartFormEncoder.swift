//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation

public struct MultipartFormEncoder: BodyEncoder {
    
    private let boundary: UUID
    
    public init(boundary: UUID) {
        self.boundary = boundary
    }
    
    public func buildBody<Parameters>(_ parameters: Parameters) throws -> Data where Parameters : Encodable {
        Data() // TODO
    }
    
}
