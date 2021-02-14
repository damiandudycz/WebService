//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation
import HandyThings
import Combine

public enum EmptyPlaceholder {
    
    case empty

}

public typealias NoResult        = EmptyPlaceholder // Used instead of Void when no result type.
public typealias NoResultDecoder = EmptyPlaceholder // Encoder for NoResult
public typealias NoParameters    = EmptyPlaceholder // Query or Body parameters

extension EmptyPlaceholder: DictionaryRepresentable {

    public func encode(to encoder: Encoder) throws {}

}

extension EmptyPlaceholder: Decodable {
    
    public init(from decoder: Decoder) throws {
        self = .empty
    }
    
}

extension EmptyPlaceholder: TopLevelDecoder {
    
    public func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable {
        EmptyPlaceholder.empty as! T
    }
    
}
