//
//  File.swift
//  
//
//  Created by Home Dudycz on 12/06/2020.
//

import UIKit

extension UIImage: MultipartFormConvertable {
    
    public enum ProvideFormBodyError: Error {
        case failedToConvertImage
    }

    public func provideFormBody(boundary: Boundary) throws -> Data {
        guard let imageData = jpegData(compressionQuality: 1.0) else {
            throw ProvideFormBodyError.failedToConvertImage
        }
        return try formBodyWithSingleData(imageData, boundary: boundary, name: "file", filename: UUID().uuidString, type: .image(.jpeg))
    }
    
}
