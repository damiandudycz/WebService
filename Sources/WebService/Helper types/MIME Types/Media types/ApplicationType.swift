//
//  File.swift
//  
//
//  Created by Damian Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    enum ApplicationType: String, CaseIterable {
        case json, octetStream = "octet-stream", pdf, zip, xml
    }
    
}
