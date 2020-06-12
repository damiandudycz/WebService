//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public protocol ResultDecoder {
    associatedtype Input
    func decode<T>(_ type: T.Type, from: Self.Input) throws -> T where T : Decodable
}

extension JSONDecoder: ResultDecoder {}
extension PropertyListDecoder: ResultDecoder {}
