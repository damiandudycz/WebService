//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation
import Combine

extension JSONEncoder: BodyEncoder {}
extension PropertyListEncoder: BodyEncoder {}

public extension BodyEncoder where Self: TopLevelEncoder, Output == Data {

    func encodeBody<Parameters: Encodable>(_ parameters: Parameters) throws -> Data {
        try encode(parameters)
    }
    
}
