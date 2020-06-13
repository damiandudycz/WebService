//
//  File.swift
//  
//
//  Created by Home Dudycz on 12/06/2020.
//

import UIKit

extension UIImage: ContentDispositionConvertable {
        
    public func contentDisposition() throws -> ContentDisposition {
        guard let data = jpegData(compressionQuality: 1.0) else {
            throw ContentDispositionConversionError.failedToConvertToData
        }
        let header = ContentDisposition.Header(contentDispositionType: .formData(name: "file", filename: UUID().uuidString))
        return ContentDisposition(header: header, data: data)
    }
    
}
