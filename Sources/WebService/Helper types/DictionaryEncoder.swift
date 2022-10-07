//
//  File.swift
//  
//
//  Created by Damian Dudycz on 10/06/2020.
//

import Foundation
import Combine
import HandyThings

public class DictionaryEncoder: TopLevelEncoder {
    
    private static let jsonEncoder = JSONEncoder()
    
    public func encode<T>(_ value: T) throws -> [String : Any] where T: Encodable {
        let jsonData = try Self.jsonEncoder.encode(value)
        guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any] else {
            throw DictionaryRepresentableError.failedToConvertToDictionary
        }
        return dictionary
    }
    
    public init() {}
    
}
