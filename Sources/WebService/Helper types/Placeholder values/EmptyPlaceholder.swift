//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation
import HandyThings
import Combine

public typealias NoResult        = EmptyPlaceholder
public typealias NoResultDecoder = EmptyPlaceholder
public typealias NoBodyEncoder   = EmptyPlaceholder
public typealias NoParameters    = EmptyPlaceholder

public enum EmptyPlaceholder {
    case empty
}

extension EmptyPlaceholder: BodyEncoder {
    public func buildBody<Parameters>(_ parameters: Parameters) throws -> Data where Parameters : Encodable {
        fatalError()
    }
}

extension EmptyPlaceholder: DictionaryRepresentable {
    public func encode(to encoder: Encoder) throws {}
}

extension EmptyPlaceholder: Decodable {
    public init(from decoder: Decoder) throws {
        self = .empty
    }
}

extension EmptyPlaceholder: TopLevelDecoder {
    public typealias Input = Data
    public func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable {
        EmptyPlaceholder.empty as! T // TODO: Could it be constrained somehow better?
    }
}
