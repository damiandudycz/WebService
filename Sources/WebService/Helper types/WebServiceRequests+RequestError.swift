//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation

public extension WebService {

    enum RequestError: Error {
        case accessTokenNotAvaliable
        case accessTokenInvalid
        case wrongResponseCode
        case apiErrors(errors: [APIErrorsResponse.APIErrors])
        case otherError(error: Error)
    }

}
