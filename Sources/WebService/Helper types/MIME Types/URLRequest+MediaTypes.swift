//
//  File.swift
//  
//
//  Created by Home Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    enum ApplicationType: String {
        case json, octetStream = "octet-stream", pdf, zip, xml
    }
    
    enum AudioType: String {
        case mpeg, aac, mpa = "MPA", mp4, ogg
    }
    
    enum ImageType: String {
        case jpeg, png, bmp, fiff, svg = "svg+xml"
    }
    
    enum ModelType: String {
        case stl, obj, mtl
    }
    
    enum MultipartType: String {
        case formData = "form-data", alternative, digest
    }
    
    enum TextType: String {
        case plain
    }
    
    enum VideoType: String {
        case mp4, h264 = "H264", h265 = "H265", mpeg4Generic = "mpeg4-generic"
    }
    
}
