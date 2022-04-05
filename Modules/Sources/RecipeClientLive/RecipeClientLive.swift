//
//  RecipeClientLive.swift
//  Receptore
//

import ComposableArchitecture
import FirebaseDatabase
import FirebaseDatabaseSwift
import RecipeClient
import Models
import SwiftUI
import UIKit


extension RecipeClient {

    public static var live: Self {
        let database = Database.database().reference().child("recipes")

        return RecipeClient(
            getRecipes: {
                .future { promise in
                    Task {
                        do {
                            let snapshot = try await database.getData()
                            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                                let error = Failure(errorDescription: "Cannot find objects recipes in realm Database")
                                promise(.failure(error))
                                return
                            }
                            let recipes = try children
                                .map { try $0.data(as: Recipe.self) }
                                .compactMap { $0 }
                            promise(.success(recipes))
                        } catch {
                            promise(.failure(.init(errorDescription: error.localizedDescription)))
                        }
                    }
                }
            },
            saveRecipe: { recipe in
                .future { promise in
                    do {
                        try database.child("/\(recipe.id)").setValue(from: recipe)
                        promise(.success(recipe))
                    } catch let error {
                        promise(.failure(.init(errorDescription: error.localizedDescription)))
                    }
                }
            },
            setFavorite: { id, isFavorite in
                .future { promise in
                    database
                        .child("/\(id)")
                        .updateChildValues(["isFavorite": isFavorite])
                    promise(.success(isFavorite))
                }
            }
        )
    }
}
