//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation
import Combine

enum EmptyBodyContent {

    // Use this instead of simple nil, to resolve Generics when needed.
    static let null: BodyContent<Data, EmptyBodyContentEncoder>? = nil
    
    enum EmptyBodyContentEncoder: BodyEncoder {
        func buildBody<Parameters: Encodable>(_ parameters: Parameters) throws -> Data {
            fatalError()
        }
    }

}
