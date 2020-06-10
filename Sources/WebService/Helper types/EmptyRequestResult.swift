//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation

public enum EmptyRequestResult: Decodable {
    
    case empty
    public init(from decoder: Decoder) throws {
        self = .empty
    }

}
