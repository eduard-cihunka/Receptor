//
//  Nutrition.swift
//  Receptor
//

import SwiftUI


public struct Nutrition: Identifiable, Equatable, Codable {

    public enum NutritionType: String, CaseIterable, Codable {
        case fat
        case fiber
        case protein
        case carbohydrates

        public var value: String {
            rawValue.capitalized
        }

        public var color: Color {
            switch self {
            case .fat: return .black
            case .fiber: return .yellow
            case .protein: return .blue
            case .carbohydrates: return .red
            }
        }
    }


    // MARK: - Properties

    public let id: UUID
    public let type: NutritionType
    public let weight: Measurement<UnitMass>
    public var formattedWeight: String { weight.description }


    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case weight = "value"
    }

    // MARK: - Initialization

    public init(id: UUID, type: Nutrition.NutritionType, weight: Double) {
        self.id = id
        self.type = type
        self.weight = Measurement(value: weight, unit: .grams)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(Nutrition.NutritionType.self, forKey: .type)
        let value = try container.decode(Double.self, forKey: .weight)
        self.weight = Measurement(value: value, unit: .grams)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(weight.value, forKey: .weight)
        try container.encode(type.rawValue, forKey: .type)
    }
}


extension Nutrition {
    public static let mockFat = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        type: .protein,
        weight: 22
    )

    public static let mockFiber = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        type: .fiber,
        weight: 24
    )
}
