//
//  AddRecipeFeatureTests.swift
//  Receptor
//

import ComposableArchitecture
import XCTest
@testable import AddRecipeFeature
import Mocks
import Models

class AddRecipeFeatureTests: XCTestCase {
    let mainQueue = DispatchQueue.immediate
    let backgroundQueue = DispatchQueue.immediate

    func testAddRecipe() {
        let testStore = TestStore(
            initialState: AddRecipeState(),
            reducer: addRecipeReducer,
            environment: .init(
                mainQueue: mainQueue.eraseToAnyScheduler(),
                backgroundQueue: backgroundQueue.eraseToAnyScheduler(),
                recipeClient: .mock,
                imageClient: .mock,
                uuid: UUID.incrementing
            )
        )

        testStore.send(.set(\.form.$title, "Recipe")) {
            $0.form.title = "Recipe"
        }

        testStore.send(.set(\.form.$description, "Good recipe")) {
            $0.form.description = "Good recipe"
        }

        testStore.send(.set(\.form.$steps, "1. Cook")) {
            $0.form.steps = "1. Cook"
        }

        testStore.send(.set(\.form.$category, .fish)) {
            $0.form.category = .fish
        }

        testStore.send(.set(\.form.$isFavorite, true)) {
            $0.form.isFavorite = true
        }

        testStore.send(.nutritionPicker(.set(\.$nutritionType, .fiber))) {
            $0.form.nutritionsState.nutritionType = .fiber
        }

        testStore.send(.nutritionPicker(.set(\.$weight, "20"))) {
            $0.form.nutritionsState.weight = "20"
        }

        testStore.send(.imagePicker(.setImage(image: UIImage()))) {
            $0.form.imagePickerState.image = UIImage()
        }

        testStore.receive(.imagePicker(.showImagePicker(isPresented: false)))

        testStore.send(.nutritionPicker(.addNutritionTapped)) {
            $0.form.nutritionsState.nutritions = [
                .init(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    type: .fiber,
                    weight: 20
                )
            ]
            $0.form.nutritionsState.weight = ""
            $0.form.nutritionsState.nutritionType = .fat
        }

        testStore.send(.saveButtonTapped) {
            $0.isSavingRecipe = true
            $0.recipeToSave = .filledRecipe
        }

        testStore.receive(.recipeSaved(.success(.filledRecipe))) {
            $0.isSavingRecipe = false
            $0.recipes.append(.filledRecipe)
            $0.recipeToSave = nil
            $0.isPresented = false
        }
    }
}

extension Recipe {
    static let filledRecipe = Recipe(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        image: UIImage(),
        name: "Recipe",
        shortDescription: "Good recipe",
        steps: "1. Cook",
        isFavorite: true,
        rating: 0,
        category: .fish,
        nutritions: [
            .init(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                type: .fiber,
                weight: 20
            )
        ]
    )
}
