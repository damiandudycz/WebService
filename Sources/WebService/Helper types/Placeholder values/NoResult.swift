//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation
import Combine

public enum NoResult: Decodable {
    
    case empty
    public init(from decoder: Decoder) throws {
        self = .empty
    }

}

public enum NoResultDecoder: TopLevelDecoder {

    case empty
    public func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable {
        NoResult.empty as! T // TODO: Could it be constrained somehow better?
    }
    public typealias Input = Data

}
