//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public class MultipartFormBodyProvider: BodyProvider {
    
    let boundary: UUID
    let parameters: MultipartFormConvertable
    
    public init(boundary: UUID, parameters: MultipartFormConvertable) {
        self.boundary = boundary
        self.parameters = parameters
    }
    
    public func provideBody() throws -> Data {
        try parameters.provideFormBody(boundary: boundary)
    }

}
