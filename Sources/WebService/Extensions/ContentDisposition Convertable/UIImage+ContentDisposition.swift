//
//  File.swift
//
//
//  Created by Damian Dudycz on 12/06/2020.
//

import UIKit

public struct ContentDispositionDataDefinition: ContentDispositionConvertable {
    
    /// Form name
    let name:        String
    let filename:    String?
    let contentType: URLRequest.ContentType?
    let data:        Data
    
    public init(name: String, filename: String? = nil, contentType: URLRequest.ContentType?, data: Data) {
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
        try contentDisposition(fieldName: "file")
    }
    
    public func contentDisposition(fieldName: String) throws -> ContentDisposition {
        guard let data = jpegData(compressionQuality: 0.75) else {
            throw ContentDispositionConversionError.failedToConvertToData
        }
        return try ContentDispositionDataDefinition(name: fieldName, filename: UUID().uuidString.appending(".jpg"), contentType: .image(.jpeg), data: data).contentDisposition()
    }
    
}

extension Data: ContentDispositionConvertable {
        
    public func contentDisposition() throws -> ContentDisposition {
        try contentDisposition(fieldName: "file")
    }
    
    public func contentDisposition(fieldName: String) throws -> ContentDisposition {
        try ContentDispositionDataDefinition(name: fieldName, contentType: nil, data: self).contentDisposition()
    }
    
}
