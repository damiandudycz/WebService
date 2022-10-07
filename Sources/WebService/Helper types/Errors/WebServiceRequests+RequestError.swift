//
//  File.swift
//  
//
//  Created by Damian Dudycz on 08/06/2020.
//

import Foundation
import HandyThings

public extension WebService {
    
    typealias ResponseStatus = URLResponse.ResponseStatus

    enum RequestError: Error, LocalizedError {
        case accessTokenNotAvaliable
        case accessTokenInvalid
        case wrongResponseStatus(status: ResponseStatus)
        case apiError(error: APIErrorType, response: URLResponse)
        case otherError(error: Error)
        
        public var errorDescription: String? {
            switch self {
            case .accessTokenNotAvaliable:
                return "Access token not available"
            case .accessTokenInvalid:
                return "Access token invalid"
            case .wrongResponseStatus(let status):
                return "Wrong response status: \(status)"
            case .apiError(let error, _):
                return "API error: \(error)"
            case .otherError(let error):
                return "Error: \(error)"
            }
        }
        
    }
    
    func requestErrorWith(error: Error) -> RequestError {
        if let requestError = error as? RequestError {
            return requestError
        }
        return .otherError(error: error)
    }

}
