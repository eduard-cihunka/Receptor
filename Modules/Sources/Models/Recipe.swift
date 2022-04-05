//
//  Recipe.swift
//  
//
//  Created by Eduard Cihuňka on 03.04.2022.
//

import Foundation
import UIKit

public struct Recipe: Codable, Equatable, Identifiable {

    public enum Category: String, Equatable, Codable, CaseIterable {
        case meat
        case vegan
        case fish
        case dessert

        public var name: String { self.rawValue.capitalized }
    }

    // MARK: - Properties

    public var id: UUID
    public var image: UIImage?
    public var name: String
    public var shortDescription: String
    public var steps: String
    public var isFavorite: Bool
    public var rating: Int
    public var category: Category
    public var nutritions: [Nutrition]
    public var isGraphPresented = false


    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortDescription
        case steps
        case isFavorite
        case rating
        case category
        case nutritions
    }


    // MARK: - Initialization

    public init(
        id: UUID,
        image: UIImage? = nil,
        name: String,
        shortDescription: String,
        steps: String,
        isFavorite: Bool,
        rating: Int,
        category: Recipe.Category,
        nutritions: [Nutrition]
    ) {
        self.id = id
        self.image = image
        self.name = name
        self.shortDescription = shortDescription
        self.steps = steps
        self.isFavorite = isFavorite
        self.rating = rating
        self.category = category
        self.nutritions = nutritions
        self.isGraphPresented = false
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.shortDescription = try container.decode(String.self, forKey: .shortDescription)
        self.steps = try container.decode(String.self, forKey: .steps)
        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        self.rating = try container.decode(Int.self, forKey: .rating)
        self.category = try container.decode(Category.self, forKey: .category)
        let nutritions = try container.decode([String: Nutrition].self, forKey: .nutritions)
        self.nutritions = nutritions.map { $0.value }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(shortDescription, forKey: .shortDescription)
        try container.encode(steps, forKey: .steps)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(rating, forKey: .rating)
        try container.encode(category, forKey: .category)
        let nutritions = Dictionary(uniqueKeysWithValues: self.nutritions.map { ($0.id.uuidString, $0)})
        try container.encode(nutritions, forKey: .nutritions)
    }
}


extension Recipe {
    public static let mock = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        image: nil,
        name: "Recipe",
        shortDescription: "Good Recipe",
        steps: """
            1. Cook

            2. Eat
        """,
        isFavorite: true,
        rating: 3,
        category: .meat,
        nutritions: [
            .mockFat,
            .mockFiber
        ]
    )
}
