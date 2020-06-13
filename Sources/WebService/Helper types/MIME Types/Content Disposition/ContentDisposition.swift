//
//  File.swift
//  
//
//  Created by Home Dudycz on 13/06/2020.
//

import Foundation

public struct ContentDisposition {
    
    public typealias Boundary = URLRequest.Boundary
        
    public init(header: Header, data: Data) {
        self.header = header
        self.data = data
    }
    
    let header: Header
    let data: Data
    
    func body(boundary: Boundary) throws -> Data {
        try header.data(boundary: boundary) + data
    }
    
}
