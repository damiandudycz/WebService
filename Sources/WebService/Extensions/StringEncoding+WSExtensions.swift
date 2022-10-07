//
//  File.swift
//  
//
//  Created by Damian Dudycz on 11/06/2020.
//

import Foundation

extension String.Encoding {
    
    var httpName: String {
        switch self {
        case .ascii:             return "US-ASCII"
        case .unicode:           return "UTF-8"
        case .utf8:              return "UTF-8"
        case .utf16:             return "UTF-16"
        case .utf16BigEndian:    return "UTF-16BE"
        case .utf16LittleEndian: return "UTF-16LE"
        case .utf32:             return "UTF-32"
        case .utf32BigEndian:    return "UTF-32BE"
        case .utf32LittleEndian: return "UTF-32LE"
        case .windowsCP1250:     return "windows-1250"
        case .windowsCP1251:     return "windows-1251"
        case .windowsCP1252:     return "windows-1252"
        case .windowsCP1253:     return "windows-1253"
        case .windowsCP1254:     return "windows-1254"
        case .nonLossyASCII:     return "ASCII"
        case .iso2022JP:         return "ISO-2022-JP"
        case .nextstep:          return "ISO-8859-1"
        case .isoLatin1:         return "ISO-8859-1"
        case .isoLatin2:         return "ISO-8859-2"
        case .japaneseEUC:       return "EUC-JP"
        case .macOSRoman:        return "x-MacRoman"
        case .shiftJIS:          return "Shift_JIS"
        case .symbol:            return "x-MacSymbol"
        default: fatalError("Unsupported encoding")
        }
    }
    
}
