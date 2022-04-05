//
//  NutritionPickerTests.swift
//  Receptor
//

import ComposableArchitecture
import XCTest
@testable import AddRecipeFeature
import Models

class NutritionPickerTests: XCTestCase {

    func testBasics() {
        let testStore = TestStore(
            initialState: NutritionPickerState(),
            reducer: nutritionPickerReducer,
            environment: .init(uuid: UUID.incrementing)
        )

        testStore.send(.set(\.$nutritionType, .fiber)) {
            $0.nutritionType = .fiber
        }

        testStore.send(.set(\.$weight, "25")) {
            $0.weight = "25"
        }
    }

    func testAddNutritionAlertReplace() {
        let testStore = TestStore(
            initialState: NutritionPickerState(),
            reducer: nutritionPickerReducer,
            environment: .init(uuid: UUID.incrementing)
        )

        testStore.send(.set(\.$nutritionType, .fiber)) {
            $0.nutritionType = .fiber
        }

        testStore.send(.set(\.$weight, "25")) {
            $0.weight = "25"
        }

        testStore.send(.addNutritionTapped) {
            $0.nutritions.append(
                Nutrition(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    type: .fiber,
                    weight: 25
                )
            )
            $0.nutritionType = .fat
            $0.weight = ""
        }

        testStore.send(.set(\.$nutritionType, .fiber)) {
            $0.nutritionType = .fiber
        }

        testStore.send(.set(\.$weight, "35")) {
            $0.weight = "35"
        }

        testStore.send(.addNutritionTapped) {
            $0.nutritionToDelete = Nutrition(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                type: .fiber,
                weight: 25
            )
        }

        testStore.receive(.showAlert) {
            $0.nutritionAlert = .init(
                title: .init("This type of nutrition is already added. Do you want to reaplce it?"),
                primaryButton: .destructive(.init("Replace"), action: .send(.onReplaceNutritionTapped)),
                secondaryButton: .cancel(.init("No"))
            )
        }

        testStore.send(.nutritionAlert(.onReplaceNutritionTapped)) {
            $0.nutritions = []
            $0.nutritionToDelete = nil
        }

        testStore.receive(.addNutritionTapped) {
            $0.nutritionType = .fat
            $0.weight = ""
            $0.nutritions.append(
                Nutrition(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                    type: .fiber,
                    weight: 35
                )
            )
        }
    }

    func testAddNutritionAlertCancel() {
        let testStore = TestStore(
            initialState: NutritionPickerState(),
            reducer: nutritionPickerReducer,
            environment: .init(uuid: UUID.incrementing)
        )

        testStore.send(.set(\.$nutritionType, .fiber)) {
            $0.nutritionType = .fiber
        }

        testStore.send(.set(\.$weight, "25")) {
            $0.weight = "25"
        }

        testStore.send(.addNutritionTapped) {
            $0.nutritions.append(
                Nutrition(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                    type: .fiber,
                    weight: 25
                )
            )
            $0.nutritionType = .fat
            $0.weight = ""
        }

        testStore.send(.set(\.$nutritionType, .fiber)) {
            $0.nutritionType = .fiber
        }

        testStore.send(.set(\.$weight, "35")) {
            $0.weight = "35"
        }

        testStore.send(.addNutritionTapped) {
            $0.nutritionToDelete = Nutrition(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                type: .fiber,
                weight: 25
            )
        }

        testStore.receive(.showAlert) {
            $0.nutritionAlert = .init(
                title: .init("This type of nutrition is already added. Do you want to reaplce it?"),
                primaryButton: .destructive(.init("Replace"), action: .send(.onReplaceNutritionTapped)),
                secondaryButton: .cancel(.init("No"))
            )
        }

        testStore.send(.nutritionAlert(.onDismiss)) {
            $0.nutritionAlert = nil
            $0.nutritionToDelete = nil
        }
    }
}
