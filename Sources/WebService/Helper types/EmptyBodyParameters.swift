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
    
    enum EmptyBodyContentEncoder: TopLevelEncoder {
        func encode<T>(_ value: T) throws -> Data where T : Encodable { fatalError() }
    }

}
