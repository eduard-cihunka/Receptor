//
//  Failure.swift
//  Receptor
//

import Foundation

public struct Failure: LocalizedError, Equatable {
    public var errorDescription: String?

    public init(errorDescription: String? = nil) {
        self.errorDescription = errorDescription
    }
}
