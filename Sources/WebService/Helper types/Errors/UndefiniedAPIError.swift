//
//  File.swift
//  
//
//  Created by Damian Dudycz on 09/06/2020.
//

import Foundation
import Combine

/// Use this as a placeholder when you API does not return Standarized Error type.
/// Decoding this kind of error will always fail, resulting in apiError never being returned as an Error.
public enum UndefiniedAPIError: Error, Decodable, TopLevelDecoder {
    
    public typealias Input = Data
    
    case undefiniedAPIError
    case decoder // Use when not using error decoding as a placeholder.
    
    public init(from decoder: Decoder) throws {
        throw UndefiniedAPIError.undefiniedAPIError
    }
    
    public func decode<T>(_ type: T.Type, from: Data) throws -> T where T : Decodable {
        UndefiniedAPIError.decoder as! T
    }
    
}
