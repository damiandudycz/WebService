//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation
import Combine
import HandyThings

public enum NoParameters: DictionaryRepresentable {
    
    public func encode(to encoder: Encoder) throws {}
    public static let null: NoParameters? = nil

}
