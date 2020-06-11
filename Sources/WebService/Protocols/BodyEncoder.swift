//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation

/// A type that can convert some parameters to Body Data.
public protocol BodyEncoder {
    
    func encodeBody<Parameters: Encodable>(_ parameters: Parameters) throws -> Data
    
}
