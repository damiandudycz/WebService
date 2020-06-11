//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation
import Combine

public typealias RawBodyFormParameters = [String : CustomStringConvertible]

public protocol BodyEncoder {
    
    func buildBody<Parameters: Encodable>(_ parameters: Parameters) throws -> Data
//    func buildBody(_ parameters: RawBodyFormParameters) throws -> Data
    
}

public extension BodyEncoder where Self: TopLevelEncoder, Output == Data {

    func buildBody<Parameters>(_ parameters: Parameters) throws -> Data where Parameters : Encodable {
        try encode(parameters)
    }
    
}

//public extension BodyEncoder {
//
//    func buildBody(_ parameters: RawBodyFormParameters) throws -> Data {
//        fatalError("Unsupported in this encoder. Please override if it's needed")
//    }
//
//}

extension JSONEncoder: BodyEncoder {}
extension PropertyListEncoder: BodyEncoder {}
