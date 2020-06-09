//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation

extension Token {
    
    struct JWT: Codable, CustomStringConvertible {
        
        private let rawValue: String
        private let accessSegment: AccessSegment
        
        var description: String {
            rawValue
        }
        
        var isExpired: Bool {
            Date().timeIntervalSince1970 >= accessSegment.exp
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            rawValue = try container.decode(String.self)
            accessSegment = try AccessSegment(rawValue)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
    }
    
}

private extension Token.JWT {
    
    struct AccessSegment: Decodable {
        enum AccessSegmentError: Error {
            case failedToDecodeAccessSegment
        }
        
        let exp: TimeInterval
        
        init(_ tokenString: String) throws {
            func base64Decode(_ base64: String) -> Data? {
                let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
                return Data(base64Encoded: padded)
            }
            let segments = tokenString.components(separatedBy: ".")
            let jwtSegment = segments[1]
            guard let bodyData = base64Decode(jwtSegment) else {
                throw AccessSegmentError.failedToDecodeAccessSegment
            }
            self = try JSONDecoder().decode(AccessSegment.self, from: bodyData)
        }
        
    }
    
}
