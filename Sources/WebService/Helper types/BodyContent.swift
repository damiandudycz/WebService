//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation

public typealias BodyContent<Parameters: Encodable, Encoder: BodyEncoder> = (
    parameters: Parameters,
    encoder:    Encoder
)
