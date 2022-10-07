//
//  WebService.swift
//
//  Created by  on 02/01/2020.
//  Copyright © 2020 . All rights reserved.
//

import Foundation
import Combine
import HandyThings

open class WebService<TokenType: WebServiceToken, APIErrorType: Decodable> {
    
    public let baseURL: URL
    
    public init(_ baseURL: URL) {
        self.baseURL = baseURL
        do {
            self.token = try TokenType.loadFromStorage()
        }
        catch {
            WebService.log("Token not loaded: Error: \(error.localizedDescription)", id: 0)
        }
        WebService.log("Loaded token: \(String(describing: self.token))", id: 0)
    }
        
    private var tokenUpdatePublisher: AnyCancellable?
    private var tokenUpdatesPromises = [(Result<TokenType, WebService<TokenType, APIErrorType>.RequestError>) -> Void]()
    
    @CurrentValue
    open var token: TokenType? {
        didSet {
            if let token = token {
                token.save()
                WebService.log("Token saved: \(token)", id: 0)
            }
            else if oldValue != nil {
                do {
                    try TokenType.deleteFromStorage()
                }
                catch {
                    WebService.log("Token delete failed: \(error.localizedDescription)", id: 0)
                    print(error)
                }
            }
        }
    }
    open func getFreshAccessToken(oldToken: TokenType) -> RequestPublisher<TokenType> {
        fatalError("Please override implementation. Suggest to use a method from container that returns new token.")
    }

}

private extension WebService {

    func url(for function: String) -> URL {
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: ";:@+$, ")
        return URL(string: baseURL.absoluteString.appending("/" + (function.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? function)))!
    }
    
}

public extension WebService {
    static var logFileURL: URL {
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
        return getDocumentsDirectory().appendingPathComponent("WebService.log")
    }
    static func log(_ string: CustomStringConvertible, id: Int, lineSpacing: Bool = false) {
        let log: String
        if #available(iOS 15.0, *) {
            log = "[WS \(id)] [\(Date().ISO8601Format())] " + string.description
        } else {
            log = "[WS \(id)] [\(Date().description)] " + string.description
        }
        print(log)
        do {
            guard let data = ((lineSpacing ? "\n" : "") + log + "\n").data(using: .utf8) else {
                throw Data.ConversionError.failedToConvertToData
            }
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                let fileHandle = try FileHandle(forWritingTo: logFileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try data.write(to: logFileURL, options: .atomicWrite)
            }
        } catch {
            print("[WS] Failed to store log!")
        }
    }
}

// Requests.
public extension WebService {
    
    typealias ContentType = URLRequest.ContentType
    typealias HTTPMethod  = URLRequest.HTTPMethod
    typealias Header      = URLRequest.Header

    func request(
        for function:    String,
        body:            Data? = nil,
        contentType:     ContentType? = nil,
        customURL:       URL? = nil,
        queryParameters: DictionaryRepresentable? = nil,
        token:           TokenType? = nil,
        method:          HTTPMethod = .get,
        headers:         [Header]? = nil,
        timeout:         TimeInterval
    ) throws -> URLRequest {
        
        let url: URL = try customURL ?? {
            guard let queryParameters = queryParameters else {
                return self.url(for: function)
            }
            let queryParametersDictionary = try queryParameters.dictionary()
            let parametersStrings = queryParametersDictionary.map { (key, value) -> String in
                if let values = value as? [CustomStringConvertible] {
                    return "\(key)=\(values.map(\.description).joined(separator: "&\(key)="))"
                }
                else {
                    return "\(key)=\(value.description)"
                }
            }
            let string = "?\(parametersStrings.joined(separator: "&"))"
            return self.url(for: function + string)
        }()
                
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeout)
        request.method = method
            
        // Prepare all headers
        let allHeaders: [Header] = {
            var allHeaders = headers ?? []
            
            if let contentType = contentType {
                allHeaders.append(.contentType(contentType))
            }
            if let body = body {
                allHeaders.append(.contentLength(body.count))
            }
            return allHeaders
        }()
        
        // Add headers to request
        allHeaders.forEach { (header) in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        // Add body
        request.httpBody = body
        
        token?.authorizeRequest(&request)
                
        return request
    }
    
}

// Request publishers.
public extension WebService {
        
    func requestPublisher<Result: Decodable, Decoder: TopLevelDecoder, ErrorDecoder: TopLevelDecoder>(
        for request:  URLRequest,
        decoder:      Decoder,
        errorDecoder: ErrorDecoder,
        reqid: Int, funct: String // TODO: Delete after testing
    ) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {
        if let headers = request.allHTTPHeaderFields {
            Self.log("  > Set headers: \(headers)", id: reqid)
        }
        if let body = request.httpBody {
            if let bodyString = String(data: body, encoding: .utf8) {
                Self.log("  > Set body: \(bodyString)", id: reqid)
            }
            else {
                Self.log("  > Set body: <BINARY DATA> \(body.count) bytes", id: reqid)
            }
        }
        
        func handleError<Result>(_ error: Error, data: Data, response: URLResponse) throws -> Result {
            if let decodedError = try? errorDecoder.decode(APIErrorType.self, from: data) {
                throw RequestError.apiError(error: decodedError, response: response)
            }
            if let error = error as? RequestError {
                throw error
            }
            throw error
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) throws -> Result in
                do {
                    Self.log("<<< Response to: \"\(funct)\" [\((response as! HTTPURLResponse).status)]", id: reqid)

                    if !data.isEmpty {
                        if let string = String(data: data, encoding: .utf8) {
                            Self.log("  < Received data: " + string, id: reqid)
                        }
                        else {
                            Self.log("  < Received data: " + "<BINARY DATA> \(data.count) bytes", id: reqid)
                        }
                    }
                    guard response.status.isSuccess else {
                        throw RequestError.wrongResponseStatus(status: response.status)
                    }
                    return try decoder.decode(Result.self, from: data)
                }
                catch {
                    print("ERROR: \(error.localizedDescription)")
                    return try handleError(error, data: data, response: response)
                }
            }
            .mapError(requestErrorWith)
            .eraseToAnyPublisher()
    }
    
    // Request publishers for Token Based API.
    /// This function will automatically obtain and store new access token if current token is expired.
    func requestPublisherWithFreshToken<Result: Decodable>(
        _ methodCreator:     @escaping RequestPublisherWithTokenCreator<Result>,
        token:               TokenType,
        tokenRefreshCreator: TokenRefreshCreator,
        requestTimeout:      TimeInterval,
        reqid:               Int
    ) -> RequestPublisher<Result> {
        
        if !token.isExpired(timeOffset: requestTimeout) {
            Self.log("  ! Token OK.", id: reqid)
            return Just(token)
                .tryMap(methodCreator)
                .mapError(requestErrorWith)
                .flatMap { $0 }
                .eraseToAnyPublisher()
        }
        
        let tokenRefreshAwaitPublisher = Future<TokenType, RequestError> { [self] (promise) in
            tokenUpdatesPromises.append(promise)
        }
        
        // If there is no publisher for getting new token, create and store one. Otherwise, just ignore
        if tokenUpdatePublisher == nil {
            Self.log("  ! Starting new token update.", id: reqid)
            tokenUpdatePublisher = tokenRefreshCreator.function(token)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        switch error {
                        case .wrongResponseStatus(let status) where status == .badRequest:
                            // Sign out
                            tokenRefreshCreator.onDenay?()
                        case let .apiError(_, response) where response.status == .badRequest:
                            tokenRefreshCreator.onDenay?()
                        default: break
                        }
                        self.tokenUpdatesPromises.forEach { (promise) in
                            promise(.failure(error))
                        }
                    }
                    self.tokenUpdatePublisher = nil
                    self.tokenUpdatesPromises.removeAll()
                }, receiveValue: { token in
                    self.token = token
                    self.tokenUpdatesPromises.forEach { (promise) in
                        promise(.success(token))
                    }
                })
        }
        else {
            Self.log("  ! Token update in progress.", id: reqid)
        }
        
        return tokenRefreshAwaitPublisher
            .tryMap(methodCreator)
            .mapError(requestErrorWith)
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }
    
}

extension WebService {

    open class APIContainer<WebServiceType: WebService> {
        
        // Alisases
        public typealias Boundary         = URLRequest.Boundary
        public typealias HTTPMethod       = WebService.HTTPMethod
        public typealias Header           = WebService.Header
        public typealias ContentType      = WebService.ContentType
        public typealias RequestPublisher = WebService.RequestPublisher

        private(set) public unowned var webService: WebServiceType!
        
        public init(webService: WebServiceType) {
            self.webService = webService
        }
        
    }

}

// Decoders / Encoders
private let globalJSONDecoder: JSONDecoder = {
    // Date sometimes is formatter with miliseconds, so we use two formatters
    let dateFormatter = ISO8601DateFormatter()
    let dateFormatterWithMS = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime]
    dateFormatterWithMS.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom({ decoder in
        let dateString = try decoder.singleValueContainer().decode(String.self)
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        if let date = dateFormatterWithMS.date(from: dateString) {
            return date
        }
        throw DecodingError.dataCorrupted(
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "Failed to decode ISO8601 date from \(dateString)",
                underlyingError: nil
            )
        )
    })
    return decoder
}()
private let globalJSONEncoder = JSONEncoder()

public extension WebService.APIContainer {

    var jsonDecoder:     JSONDecoder { globalJSONDecoder }
    var jsonEncoder:     JSONEncoder { globalJSONEncoder }
    var noResultDecoder: NoResultDecoder { .empty }
    
    // Body content / Parameters
    var noParameters: NoParameters? { nil }
    
    func jsonBodyProvider<Parameters: Encodable>(_ parameters: Parameters) -> BodyProvider {
        EncoderBasedBodyProvider(encoder: jsonEncoder, parameters: parameters)
    }
    
    func multipartFormBodyProvider(boundary: Boundary = Boundary(), parts: ContentDispositionConvertable...) -> MultipartForm {
        MultipartForm(boundary: boundary, parts: parts)
    }

    func multipartFormBodyProvider(boundary: Boundary = Boundary(), parts: [ContentDispositionConvertable]) -> MultipartForm {
        MultipartForm(boundary: boundary, parts: parts)
    }
    
    // Publisher
    func constructPublisher<ErrorDecoder: TopLevelDecoder>(

        endpoint:        String,
        method:          HTTPMethod = .get,
        headers:         [Header]? = nil,
        customURL:       URL? = nil,
        timeout:         TimeInterval = 30,

        contentType:     ContentType? = .application(.json, encoding: .utf8),

        queryParameters: DictionaryRepresentable? = nil,
        bodyProvider:    BodyProvider? = nil,

        errorDecoder:    ErrorDecoder,

        requiresToken:   Bool = false

    ) -> RequestPublisher<NoResult> where ErrorDecoder.Input == Data {
        constructPublisher(endpoint: endpoint, method: method, headers: headers, customURL: customURL, timeout: timeout, contentType: contentType, queryParameters: queryParameters, bodyProvider: bodyProvider, decoder: noResultDecoder, errorDecoder: errorDecoder, requiresToken: requiresToken)
    }
    
    // Publisher
    func constructPublisher(

        endpoint:        String,
        method:          HTTPMethod = .get,
        headers:         [Header]? = nil,
        customURL:       URL? = nil,
        timeout:         TimeInterval = 30,
        
        contentType:     ContentType? = .application(.json, encoding: .utf8),

        queryParameters: DictionaryRepresentable? = nil,
        bodyProvider:    BodyProvider? = nil,

        requiresToken:   Bool = false

    ) -> RequestPublisher<NoResult> {
        constructPublisher(endpoint: endpoint, method: method, headers: headers, customURL: customURL, timeout: timeout, contentType: contentType, queryParameters: queryParameters, bodyProvider: bodyProvider, errorDecoder: globalJSONDecoder, requiresToken: requiresToken)
    }
    
    // Publisher
    func constructPublisher<
        Result:       Decodable,
        Decoder:      TopLevelDecoder,
        ErrorDecoder: TopLevelDecoder>(

        endpoint:        String,
        method:          HTTPMethod = .get,
        headers:         [Header]? = nil,
        customURL:       URL? = nil,
        timeout:         TimeInterval = 30,

        contentType:     ContentType? = .application(.json, encoding: .utf8),

        queryParameters: DictionaryRepresentable? = nil,
        bodyProvider:    BodyProvider? = nil,

        decoder:         Decoder,
        errorDecoder:    ErrorDecoder,

        requiresToken:   Bool = false

    ) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {
        let reqid = wsreqid
        wsreqid += 1

        do {
            WebService.log(">>> Preparing new request [\(method.rawValue.uppercased())] [\(requiresToken ? "Secure" : "Open")] \"\(endpoint)\"", id: reqid)
            if let queryParameters = queryParameters {
                WebService.log("  > Set query parameters: \(try queryParameters.dictionary())", id: reqid)
            }
            if let customURL = customURL {
                WebService.log("  > Set custom url: \(customURL)", id: reqid)
            }
            
            func methodCreator<Result: Decodable>(_ token: TokenType?) throws -> RequestPublisher<Result> {
                let body = try bodyProvider?.provideBody()
                let request = try webService.request(for: endpoint, body: body, contentType: contentType, customURL: customURL, queryParameters: queryParameters, token: token, method: method, headers: headers, timeout: timeout)
                return webService.requestPublisher(for: request, decoder: decoder, errorDecoder: errorDecoder, reqid: reqid, funct: endpoint)
            }

            if requiresToken {
                guard let token = webService.token else {
                    WebService.log("<<< Fail: \(RequestPublisher<Result>.Failure.accessTokenNotAvaliable)", id: reqid)
                    return Fail(error: .accessTokenNotAvaliable).eraseToAnyPublisher()
                }
                let tokenRefreshCreator: WebService.TokenRefreshCreator = (function: webService.getFreshAccessToken, onDenay: { [self] in
                    WebService.log("  ! Token refresh denyed", id: reqid)
                    webService.token = nil
                })
                return webService.requestPublisherWithFreshToken(methodCreator, token: token, tokenRefreshCreator: tokenRefreshCreator, requestTimeout: timeout, reqid: reqid)
            }
            else {
                return try methodCreator(nil)
            }
        }
        catch {
            WebService.log("<<< Failure: \(error)", id: reqid)
            return Fail(error: .otherError(error: error)).eraseToAnyPublisher()
        }
    }
    
    func constructTestingPublisher<
        Result:       Decodable,
        Decoder:      TopLevelDecoder,
        ErrorDecoder: TopLevelDecoder>(
            fakeResponse:    String,
            decoder:         Decoder,
            errorDecoder:    ErrorDecoder
        ) -> RequestPublisher<Result> where Decoder.Input == Data, ErrorDecoder.Input == Data {
            guard let data = fakeResponse.data(using: .utf8) else {
                return Fail(error: .otherError(error: Data.ConversionError.failedToConvertToData)).eraseToAnyPublisher()
            }
            
            return Just(fakeResponse)
                .tryMap { (fakeResponse) throws -> Result in
                    try decoder.decode(Result.self, from: data)
                }
                .mapError(webService.requestErrorWith)
                .eraseToAnyPublisher()
            
        }
}

public protocol WebServiceToken {
    // Is this token still valid - if it is it will not require getting new token
//    var authorizationString: String { get }
    func isExpired(timeOffset: TimeInterval) -> Bool
    func save()
    func authorizeRequest(_ request: inout URLRequest)
    static func deleteFromStorage() throws
    static func loadFromStorage() throws -> Self?
}

private var wsreqid = 1
