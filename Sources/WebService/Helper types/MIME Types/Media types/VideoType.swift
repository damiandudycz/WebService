//
//  File.swift
//  
//
//  Created by Damian Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    enum VideoType: String, CaseIterable {
        case mp4, h264 = "H264", h265 = "H265", mpeg4Generic = "mpeg4-generic"
    }
    
}
