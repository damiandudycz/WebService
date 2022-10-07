//
//  File.swift
//  
//
//  Created by Damian Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    enum ImageType: String, CaseIterable {
        case jpeg, png, bmp, fiff, svg = "svg+xml"
    }
    
}
