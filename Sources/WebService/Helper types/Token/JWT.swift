//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation

extension Token {
    
    public struct JWT: Codable, CustomStringConvertible {
        
        public let rawValue: String
        public let accessSegment: AccessSegment // Encoded from raw value.
        
        public var description: String {
            rawValue
        }
        
        var isExpired: Bool {
            Date().timeIntervalSince1970 >= accessSegment.exp
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            rawValue = try container.decode(String.self)
            accessSegment = try AccessSegment(rawValue)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
        
    }
    
}

public extension Token.JWT {
    
    struct AccessSegment: Decodable {
        enum AccessSegmentError: Error {
            case failedToDecodeAccessSegment
        }
        
        public let exp: TimeInterval
        public let email: String
        
        init(_ jsonString: String) throws {
            func base64Decode(_ base64: String) -> Data? {
                let padded = base64.padding(toLength: ((base64.count + 3) / 4) * 4, withPad: "=", startingAt: 0)
                return Data(base64Encoded: padded)
            }
            let segments = jsonString.components(separatedBy: ".")
            let jwtSegment = segments[1]
            guard let bodyData = base64Decode(jwtSegment) else {
                throw AccessSegmentError.failedToDecodeAccessSegment
            }
            self = try JSONDecoder().decode(AccessSegment.self, from: bodyData)
            print(self)
        }
        
        enum CodingKeys: String, CodingKey {
            case exp
            case email = #"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"#
        }
        
    }
    
}
