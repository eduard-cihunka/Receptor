//
//  RecipeFeatureTests.swift
//  Receptor
//

import ComposableArchitecture
import XCTest
@testable import RecipeFeature
import Models

class RecipeFeatureTests: XCTestCase {
    let mainQueue = DispatchQueue.immediate
    let backgroundQueue = DispatchQueue.immediate

    func testOnAppear() {
        let testStore = TestStore(
            initialState: .mock,
            reducer: recipeReducer,
            environment: .init(
                mainQueue: mainQueue.eraseToAnyScheduler(),
                backgroundQueue: backgroundQueue.eraseToAnyScheduler(),
                recipeClient: .mock,
                imageClient: .mock
            )
        )

        testStore.send(.onAppear)

        testStore.receive(.setImage(.success(UIImage()))) {
            $0.image = UIImage()
        }
    }

    func testFavoriteButtonTapped() {
        let testStore = TestStore(
            initialState: .mock,
            reducer: recipeReducer,
            environment: .init(
                mainQueue: mainQueue.eraseToAnyScheduler(),
                backgroundQueue: backgroundQueue.eraseToAnyScheduler(),
                recipeClient: .mock,
                imageClient: .mock
            )
        )

        testStore.send(.favoriteButtonTapped)

        testStore.receive(.saveFavorite(.success(false))) {
            $0.isFavorite = false
        }

        testStore.send(.favoriteButtonTapped)

        testStore.receive(.saveFavorite(.success(true))) {
            $0.isFavorite = true
        }
    }
}
