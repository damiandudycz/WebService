//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation
import Combine

public protocol BodyEncoder {
    
    func buildBody<Parameters: Encodable>(_ parameters: Parameters) throws -> Data

}

public extension BodyEncoder where Self: TopLevelEncoder, Output == Data {

    func buildBody<Parameters>(_ parameters: Parameters) throws -> Data where Parameters : Encodable {
        try encode(parameters)
    }

}

extension JSONEncoder: BodyEncoder {}
extension PropertyListEncoder: BodyEncoder {}
