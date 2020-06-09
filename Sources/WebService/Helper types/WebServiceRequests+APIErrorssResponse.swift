//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation

public extension WebService {

    struct APIErrorsResponse: Decodable {
        public struct APIErrors: Decodable {
            let message: String
            let code: String
        }
        let errors: [APIErrors]
    }

}
