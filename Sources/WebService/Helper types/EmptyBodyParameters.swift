//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation

public enum EmptyBodyContent {

    // Use this instead of simple nil, to resolve Generics when needed.
    public static let null: (parameters: Data, encoder: EmptyBodyContentEncoder)? = nil
    
    public enum EmptyBodyContentEncoder: RequestBodyEncoder {
        public func encode<T>(_ value: T) throws -> Data where T : Encodable { fatalError() }
    }

}
