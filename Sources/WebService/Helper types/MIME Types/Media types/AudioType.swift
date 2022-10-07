//
//  File.swift
//  
//
//  Created by Damian Dudycz on 11/06/2020.
//

import Foundation

public extension URLRequest {
    
    enum AudioType: String, CaseIterable {
        case mpeg, aac, mpa = "MPA", mp4, ogg
    }
    
}
