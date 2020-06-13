//
//  File.swift
//  
//
//  Created by Home Dudycz on 13/06/2020.
//

import Foundation

public extension ContentDisposition.Header {
    
    enum HeaderType {
        
        case formData(name: String?, filename: String?)
        
        var string: String {
            func extractPropertyString(_ string: String?, key: String) -> String {
                guard let string = string else { return String() }
                return "; \(key)=\"" + string + "\""
            }
            switch self {
            case let .formData(name, filename):
                let nameString = extractPropertyString(name, key: "name")
                let filenameString = extractPropertyString(filename, key: "filename")
                return "form-data\(nameString)\(filenameString)"
            }
        }
        
    }

}
