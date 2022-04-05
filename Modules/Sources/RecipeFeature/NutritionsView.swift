//
//  NutritionsView.swift
//  Receptor
//

import SwiftUI
import ComposableArchitecture
import Models


// MARK: - State

struct NutritionsState: Equatable {
    internal init(nutritions: [Nutrition], isGraphPresented: Bool = false) {
        self.nutritions = nutritions
        self.isGraphPresented = isGraphPresented
    }

    var nutritions: [Nutrition]
    var isGraphPresented = false
}


// MARK: - Actions

public enum NutritionsAction: Equatable {
    case setGraphSheet(isPresented: Bool)
}


// MARK: - Reducer

let nutritionsReducer = Reducer<NutritionsState, NutritionsAction, Void> { state, action, _ in
    switch action {
    case .setGraphSheet(true):
        state.isGraphPresented = true
        return .none

    case .setGraphSheet(false):
        state.isGraphPresented = false
        return .none

    }
}


// MARK: - View

struct NutritionsView: View {
    let store: Store<NutritionsState, NutritionsAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Nutritions")
                        .font(.system(size: 20, weight: .bold))

                    Spacer()

                    Button("Graph") { viewStore.send(.setGraphSheet(isPresented: true)) }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(viewStore.nutritions) {
                        Text("\($0.type.value) \($0.formattedWeight)")
                            .font(.system(size: 14))
                    }
                }
                .padding(.horizontal)
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isGraphPresented,
                    send: .setGraphSheet(isPresented: false)
                )
            ) {
                NutritionsGraph(nutritions: viewStore.nutritions)
            }
        }
    }
}

struct NutritionsView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionsView(
            store: .init(
                initialState: NutritionsState(
                    nutritions: [
                        .init(id: UUID(), type: .fat, weight: 35),
                        .init(id: UUID(), type: .fiber, weight: 25),
                        .init(id: UUID(), type: .carbohydrates, weight: 45),
                        .init(id: UUID(), type: .protein, weight: 15)
                    ]
                ),
                reducer: nutritionsReducer,
                environment: ()
            )
        )
    }
}
