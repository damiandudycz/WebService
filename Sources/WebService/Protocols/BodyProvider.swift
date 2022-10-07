//
//  File 2.swift
//  
//
//  Created by Damian Dudycz on 11/06/2020.
//

import Foundation

/// Something that can be used to create a body for the request. It can for example store parameters and function.
/// It will be asked to provide body when needed.
/// Providers should use some BodyEncoders to provide data from stored properties.
public protocol BodyProvider {
    
    func provideBody() throws -> Data

}
