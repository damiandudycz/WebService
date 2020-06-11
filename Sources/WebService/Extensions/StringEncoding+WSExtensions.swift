//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

extension String.Encoding {
    
    var httpName: String {
        switch self {
            // TODO: Fill this list with HTTP supported charsets.
        case .ascii: return "us-ascii"
        case .utf8:  return "utf-8"
        default: fatalError("Unsupported encoding")
        }
    }
    
}
