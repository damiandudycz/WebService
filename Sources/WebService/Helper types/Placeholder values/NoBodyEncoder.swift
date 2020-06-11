//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public enum NoBodyEncoder: BodyEncoder {
    case empty
    public func buildBody<Parameters>(_ parameters: Parameters) throws -> Data where Parameters : Encodable {
        fatalError()
    }
}
