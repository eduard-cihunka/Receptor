//
//  RecipesFeatureTests.swift
//  Receptor
//

import ComposableArchitecture
import XCTest
@testable import RecipesFeature
import Models
import Mocks

class RecipesFeatureTests: XCTestCase {
    let mainQueue = DispatchQueue.immediate
    let backgroundQueue = DispatchQueue.immediate

    func testShowAddRecipe() {
        let testStore = TestStore(
            initialState: RecipesState(),
            reducer: recipesReducer,
            environment: .init(
                mainQueue: mainQueue.eraseToAnyScheduler(),
                backgroundQueue: backgroundQueue.eraseToAnyScheduler(),
                recipeClient: .mock,
                imageClient: .mock,
                uuid: UUID.incrementing
            )
        )

        testStore.send(.addRecipeButtonTapped) {
            $0.addRecipe = .init()
        }
    }

    func testSelectFilter() {
        let testStore = TestStore(
            initialState: RecipesState(),
            reducer: recipesReducer,
            environment: .init(
                mainQueue: mainQueue.eraseToAnyScheduler(),
                backgroundQueue: backgroundQueue.eraseToAnyScheduler(),
                recipeClient: .mock,
                imageClient: .mock,
                uuid: UUID.incrementing
            )
        )

        testStore.send(.selectFilter(.favorite)) {
            $0.filter = .favorite
        }

        testStore.send(.selectFilter(.vegan)) {
            $0.filter = .vegan
        }

        testStore.send(.selectFilter(.all)) {
            $0.filter = .all
        }
    }
}
