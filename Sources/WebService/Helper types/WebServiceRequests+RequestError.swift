//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation

public extension WebService {

    enum RequestError: Error {
        case failedToReadResponse
        case accessTokenNotAvaliable
        case accessTokenInvalid
        case wrongResponseCode(code: Int)
        case apiError(error: APIErrorType, response: URLResponse)
        case otherError(error: Error)
    }

}
