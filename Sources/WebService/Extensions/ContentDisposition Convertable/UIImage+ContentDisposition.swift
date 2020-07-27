//
//  File.swift
//  
//
//  Created by Home Dudycz on 12/06/2020.
//

import UIKit

public struct ContentDispositionDataDefinition: ContentDispositionConvertable {
    
    /// Form name
    let name:        String
    let filename:    String
    let contentType: URLRequest.ContentType?
    let data:        Data
    
    public init(name: String, filename: String, contentType: URLRequest.ContentType?, data: Data) {
        self.name = name
        self.filename = filename
        self.contentType = contentType
        self.data = data
    }
    
    public func contentDisposition() throws -> ContentDisposition {
        let header = ContentDisposition.Header(contentDispositionType: .formData(name: name, filename: filename), contentType: contentType)
        return ContentDisposition(header: header, data: data)
    }
    
}

public struct ContentDispositionFileDefinition: ContentDispositionConvertable {
    
    /// Form name
    let name:        String
    let filename:    String
    let contentType: URLRequest.ContentType?
    let url:         URL
    
    public init(name: String, filename: String, contentType: URLRequest.ContentType?, url: URL) {
        self.name = name
        self.filename = filename
        self.contentType = contentType
        self.url = url
    }

    public func contentDisposition() throws -> ContentDisposition {
        let data = try Data(contentsOf: url)
        return try ContentDispositionDataDefinition(name: name, filename: filename, contentType: contentType, data: data).contentDisposition()
    }
    
}

extension UIImage: ContentDispositionConvertable {
        
    public func contentDisposition() throws -> ContentDisposition {
        guard let data = jpegData(compressionQuality: 1.0) else {
            throw ContentDispositionConversionError.failedToConvertToData
        }
        return try ContentDispositionDataDefinition(name: "file", filename: UUID().uuidString.appending(".jpg"), contentType: .image(.jpeg), data: data).contentDisposition()
    }
    
}

extension Data: ContentDispositionConvertable {
    
    public func contentDisposition() throws -> ContentDisposition {
        try ContentDispositionDataDefinition(name: "file", filename: UUID().uuidString, contentType: nil, data: self).contentDisposition()
    }
    
}
