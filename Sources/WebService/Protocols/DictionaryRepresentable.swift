//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation

public protocol DictionaryRepresentable: Encodable {
    
    func dictionary() throws -> [String : CustomStringConvertible]
        
}

public extension DictionaryRepresentable {
    
    func dictionary() throws -> [String : CustomStringConvertible] {
        let data = try JSONEncoder().encode(self)
        // Note - For some reason converting directly to [String : CustomStringConvertible] doesnt work. We need to convert to [String : Any] first.
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] as? [String : CustomStringConvertible] else {
            throw DictionaryRepresentableError.failedToConvertToDictionary
        }
        return dictionary
    }
    
}

enum DictionaryRepresentableError: Error {
    case failedToConvertToDictionary
}
