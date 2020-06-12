//
//  File.swift
//  
//
//  Created by Home Dudycz on 10/06/2020.
//

import Foundation
import UIKit
import HandyThings

/// A Body encoder, that converts some supported types into Multi Part Form.
//public struct MultipartFormBodyEncoder: BodyEncoder {
//    
//    public enum EncodingError: Error {
//        case unsupportedParametersType
//        case conversionFailed
//    }
//    
//    public typealias Boundary = URLRequest.Boundary
//    
//    private let boundary: Boundary
//    
//    public init(boundary: Boundary) {
//        self.boundary = boundary
//    }
//    
//    public func encodeBody<Parameters>(_ parameters: Parameters) throws -> Data {
//
//        // TODO: Other parameters types.
//        switch parameters {
//        case let data as Data:
//            // TODO: Prehaps we should pass type in Encoder initializer instead.
//            return buildFormBody(data, name: "file", filename: UUID(), type: .application())
//        case let image as UIImage:
//            guard let data = image.jpegData(compressionQuality: 1.0) else {
//                throw EncodingError.conversionFailed
//            }
//            // TODO: Select image type as a property in MultipartFormBodyEncoder
//            return buildFormBody(data, name: "file", filename: "\(UUID()).jpg", type: .image(.jpeg))
//        // TODO: Verify these below
//        case let dictionaryRepresentable as DictionaryRepresentable:
//            let dictionary = try dictionaryRepresentable.dictionary()
//            return buildFormBody(dictionary)
//        case let formParameters as [String : CustomStringConvertible]: // TODO: Is this needed?
//            return buildFormBody(formParameters)
//        default:
//            throw EncodingError.unsupportedParametersType
//        }
//        
//    }
//    
//}
//
//private extension MultipartFormBodyEncoder {
//    
//    // Form fragments adding
//    func insert(_ data: Data, name: String, filename: String?, type: URLRequest.ContentType, to body: inout Data) {
//        var part = Data()
//        // TODO: Extension for string -> Data conversion.
//        part.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
//        part.append("Content-Disposition: form-data; name=\"\(name)\"".data(using: .utf8)!)
//        if let filename = filename {
//            part.append("; filename=\"\(filename)\"".data(using: .utf8)!)
//        }
//        part.append("\r\n".data(using: .utf8)!)
//        part.append("Content-Type: \(type.string)\r\n\r\n".data(using: .utf8)!)
//        part.append(data)
//        body.append(part)
//    }
//    
//    // Finishing form
//    func finishForm(_ body: inout Data) {
//        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
//    }
//
//    // MARK: - Adding various data types
//    
//    func buildFormBody(_ data: Data, name: String, filename: CustomStringConvertible?, type: URLRequest.ContentType) -> Data {
//        var form = Data()
//        insert(data, name: name, filename: filename?.description, type: type, to: &form)
//        finishForm(&form)
//        return form
//    }
//
//    func buildFormBody(_ dictionary: [String : CustomStringConvertible]) -> Data {
//        var form = Data()
//        dictionary.forEach { (key, value) in
//            let data = value.description.data(using: .utf8)!
//            insert(data, name: key, filename: nil, type: .text(), to: &form)
//        }
//        finishForm(&form)
//        return form
//    }
//
//}
