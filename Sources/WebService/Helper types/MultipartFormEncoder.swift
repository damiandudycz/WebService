//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation

public struct MultipartFormEncoder: BodyEncoder {
    
    public typealias Boundary = URLRequest.Boundary
    
    private let boundary: Boundary
    
    public init(boundary: Boundary) {
        self.boundary = boundary
    }
    
    public func buildBody<Parameters>(_ parameters: Parameters) throws -> Data where Parameters : Encodable {
//        Data() // TODO!!!!!!!!!!!!!!
        return "--\(boundary)--".data(using: .utf8)!
    }
    
}
