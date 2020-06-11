//
//  File 2.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public protocol BodyContentMaker {
    func prepareBody() throws -> Data?
}
