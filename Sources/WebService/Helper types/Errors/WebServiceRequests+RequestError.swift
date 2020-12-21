//
//  File.swift
//  
//
//  Created by Home Dudycz on 08/06/2020.
//

import Foundation
import HandyThings

public extension WebService {
    
    typealias ResponseStatus = URLResponse.ResponseStatus

    enum RequestError: Error {
        case failedToReadResponse
        case accessTokenNotAvaliable
        case accessTokenInvalid
        case wrongResponseStatus(status: ResponseStatus)
        case apiError(error: APIErrorType, response: URLResponse)
        case otherError(error: Error)
    }
    
    func requestErrorWith(error: Error) -> RequestError {
        if let requestError = error as? RequestError {
            return requestError
        }
        return .otherError(error: error)
    }

}
