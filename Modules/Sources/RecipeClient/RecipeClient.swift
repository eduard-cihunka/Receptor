//
//  RecipeClient.swift
//  Receptor
//

import Foundation
import Models
import ComposableArchitecture
import UIKit


public struct RecipeClient {
    public var getRecipes: () -> Effect<[Recipe], Failure>
    public var saveRecipe: (Recipe) -> Effect<Recipe, Failure>
    public var setFavorite: (UUID, Bool) -> Effect<Bool, Failure>

    public init(
        getRecipes: @escaping () -> Effect<[Recipe], Failure>,
        saveRecipe: @escaping (Recipe) -> Effect<Recipe, Failure>,
        setFavorite: @escaping (UUID, Bool) -> Effect<Bool, Failure>
    ) {
        self.getRecipes = getRecipes
        self.saveRecipe = saveRecipe
        self.setFavorite = setFavorite
    }
}

extension RecipeClient {
    public static let mock = RecipeClient(
        getRecipes: { .init(value: [.mock]) },
        saveRecipe: { recipe in .init(value: recipe) },
        setFavorite: { _, isFavorite in .init(value: isFavorite) }
    )

    public static let failing = RecipeClient(
        getRecipes: { .failing("Uninplemented") },
        saveRecipe: { _  in .failing("Uninplemented") },
        setFavorite: { _,_ in .failing("Uninplemented") }
    )
}
