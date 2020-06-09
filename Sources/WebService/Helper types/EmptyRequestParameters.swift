//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation

// Placeholder for no parameters.
public enum EmptyRequestParameters: Encodable {
    
    case empty
    public func encode(to encoder: Encoder) throws {}
    public static let null: EmptyRequestParameters? = nil
    
}
