//
//  File.swift
//  
//
//  Created by Damian Dudycz on 12/06/2020.
//

import Foundation

public protocol ContentDispositionConvertable {
    
    func contentDisposition() throws -> ContentDisposition
    
}

public enum ContentDispositionConversionError: Error {
    
    case failedToConvertToData
    case failedToConvertHeaderToData

}
