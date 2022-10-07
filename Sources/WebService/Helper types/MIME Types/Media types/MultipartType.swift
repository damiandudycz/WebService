//
//  File.swift
//  
//
//  Created by Damian Dudycz on 13/06/2020.
//

import Foundation

public extension URLRequest {
    
    enum MultipartType: String, CaseIterable {
        case formData = "form-data", alternative, digest
    }
    
}
