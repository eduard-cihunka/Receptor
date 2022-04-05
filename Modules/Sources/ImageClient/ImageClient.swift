//
//  ImageClient.swift
//  Receptor
//

import Foundation
import ComposableArchitecture
import UIKit
import Models


public struct ImageClient {

    public var saveImage: (UIImage, UUID) -> Effect<UIImage, Failure>
    public var getImage: (UUID) -> Effect<UIImage, Failure>

    public init(
        saveImage: @escaping (UIImage, UUID) -> Effect<UIImage, Failure>,
        getImage: @escaping (UUID) -> Effect<UIImage, Failure>
    ) {
        self.saveImage = saveImage
        self.getImage = getImage
    }
}

extension ImageClient {
    public static let mock = Self(
        saveImage: { _, _ in Effect(value: UIImage()) },
        getImage: { _ in Effect(value: UIImage()) }
    )

    public static let failing = Self(
        saveImage: { _, _ in .failing("Uninplemented") },
        getImage: { _ in .failing("Uninplemented") }
    )
}
