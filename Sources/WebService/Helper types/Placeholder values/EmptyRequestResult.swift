//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation
import Combine

public enum EmptyRequestResult: Decodable {
    
    case empty
    public init(from decoder: Decoder) throws {
        self = .empty
    }

}

enum EmptyRequestResultDecoder: TopLevelDecoder {

    case empty
    func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable {
        EmptyRequestResult.empty as! T // TODO: Could it be constrained somehow better?
    }
    typealias Input = Data

}
