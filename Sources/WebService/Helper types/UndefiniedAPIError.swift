//
//  File.swift
//  
//
//  Created by Home Dudycz on 09/06/2020.
//

import Foundation

/// Use this as a placeholder when you API does not return Standarized Error type.
/// Decoding if this kind of error will always fail, resulting in apiError never being returned as an Error.
public enum UndefiniedAPIError: Error, Decodable {
    
    case undefiniedAPIError
    
    public init(from decoder: Decoder) throws {
        throw UndefiniedAPIError.undefiniedAPIError
    }
    
}
