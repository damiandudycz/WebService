//
//  File.swift
//  
//
//  Created by Damian Dudycz on 04/09/2021.
//

import Foundation

public struct FakeToken: WebServiceToken {
    public static let shared = FakeToken()
    public func save() {}
    public func isExpired(timeOffset: TimeInterval) -> Bool { true }
    public static func deleteFromStorage() throws {}
    public static func loadFromStorage() throws -> FakeToken? { nil }
    public func authorizeRequest(_ request: inout URLRequest) {}
}
