//
//  NutritionPickerView.swift
//  Receptor
//

import SwiftUI
import ComposableArchitecture
import Models


// MARK: - State

public struct NutritionPickerState: Equatable {

    @BindableState var nutritionType: Nutrition.NutritionType = .fat
    @BindableState var weight: String = ""

    var nutritions: IdentifiedArrayOf<Nutrition> = []
    var nutritionAlert: AlertState<NutritionPickerAction.NutritionAlert>?
    var nutritionToDelete: Nutrition?
    var addNutritionEnabled: Bool { !weight.isEmpty }

    public init() {}
}


// MARK: - Action

public enum NutritionPickerAction: Equatable, BindableAction {
    case binding(BindingAction<NutritionPickerState>)
    case addNutritionTapped
    case showAlert
    case nutritionAlert(NutritionAlert)

    public enum NutritionAlert: Equatable {
        case onReplaceNutritionTapped
        case onDismiss
    }
}


struct NutritionPickerEnvironment {
    var uuid: () -> UUID
}

// MARK: - Reducer

let nutritionPickerReducer = Reducer<
    NutritionPickerState, NutritionPickerAction, NutritionPickerEnvironment
> { state, action, environment in
    switch action {
    case .binding:
        return .none

    case .addNutritionTapped:
        if let nutrition = state.nutritions.first(where: { $0.type == state.nutritionType }) {
            state.nutritionToDelete = nutrition
            return Effect(value: .showAlert)
        }

        let nutrition = Nutrition(
            id: environment.uuid(),
            type: state.nutritionType,
            weight: Double(state.weight) ?? 0
        )
        state.nutritions.append(nutrition)
        state.nutritionType = .fat
        state.weight = ""
        return .none

    case .showAlert:
        state.nutritionAlert = .replaceAlert
        return .none

    case .nutritionAlert(.onReplaceNutritionTapped):
        if let nutrition = state.nutritionToDelete {
            state.nutritions.remove(nutrition)
        }
        state.nutritionToDelete = nil
        return Effect(value: .addNutritionTapped)

    case .nutritionAlert(.onDismiss):
        state.nutritionAlert = nil
        state.nutritionToDelete = nil
        return .none

    }
}
.binding()


// MARK: - View

struct NutritionPickerView: View {
    let store: Store<NutritionPickerState, NutritionPickerAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            if !viewStore.nutritions.isEmpty {
                Section("Nutritions") {
                    ForEach(viewStore.nutritions) {
                        Text("\($0.type.value) \($0.formattedWeight)")
                    }
                }
            }

            Section("Add nutrition") {
                Picker(
                    "Nutrition",
                    selection: viewStore.binding(\.$nutritionType)
                ) {
                    ForEach(Nutrition.NutritionType.allCases, id: \.self) { filter in
                        Text(filter.value).tag(filter)
                    }
                }

                HStack {
                    TextField("Grams", text: viewStore.binding(\.$weight))
                        .keyboardType(.numberPad)
                    Button(action: { withAnimation { viewStore.send(.addNutritionTapped) } }) {
                        Image(systemName: "plus.circle.fill")
                            .padding(8)
                    }
                    .disabled(!viewStore.addNutritionEnabled)
                }
            }
            .alert(
                self.store.scope(
                    state: \.nutritionAlert,
                    action: NutritionPickerAction.nutritionAlert
                ),
                dismiss: .onDismiss
            )
        }
    }
}


// MARK: - Preview

struct NutritionPickerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                NutritionPickerView(
                    store: .init(
                        initialState: .init(),
                        reducer: nutritionPickerReducer,
                        environment: .init(uuid: { UUID() })
                    )
                )
            }
        }
    }
}


// MARK: - Extensions

extension AlertState where Action == NutritionPickerAction.NutritionAlert {
    static let replaceAlert: Self = .init(
        title: .init("This type of nutrition is already added. Do you want to reaplce it?"),
        primaryButton: .destructive(.init("Replace"), action: .send(.onReplaceNutritionTapped)),
        secondaryButton: .cancel(.init("No"))
    )
}
