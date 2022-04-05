//
//  RecipeView.swift
//  Receptor
//
//  Created by Eduard Cihuňka on 27.03.2022.
//

import SwiftUI
import ComposableArchitecture
import Models
import Views
import RecipeClient
import ImageClient


// MARK: - State

extension Recipe {
    var nutritionsState: NutritionsState {
        get { .init(nutritions: nutritions, isGraphPresented: isGraphPresented) }
        set { isGraphPresented = newValue.isGraphPresented }
    }
}


// MARK: - Actions

public enum RecipeAction: Equatable {
    case onAppear
    case favoriteButtonTapped
    case saveFavorite(Result<Bool, Failure>)
    case setImage(Result<UIImage, Failure>)
    case nutritions(NutritionsAction)
}


// MARK: - Environment

public struct RecipeEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var backgroundQueue: AnySchedulerOf<DispatchQueue>
    var recipeClient: RecipeClient
    var imageClient: ImageClient

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        recipeClient: RecipeClient,
        imageClient: ImageClient
    ) {
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.recipeClient = recipeClient
        self.imageClient = imageClient
    }
}


// MARK: - Reducer

public let recipeReducer = Reducer<Recipe, RecipeAction, RecipeEnvironment>.combine(
    nutritionsReducer
        .pullback(
            state: \.nutritionsState,
            action: /RecipeAction.nutritions,
            environment: { _ in () }
        ),

    Reducer { state, action, environment in
        switch action {
        case .onAppear:
            return state.image != nil
                ? .none
                : environment
                    .imageClient
                    .getImage(state.id)
                    .subscribe(on: environment.backgroundQueue)
                    .receive(on: environment.mainQueue)
                    .catchToEffect(RecipeAction.setImage)

        case .setImage(.success(let image)):
            state.image = image
            return .none

        case .setImage(.failure(let error)):
            print(error)
            return .none

        case .favoriteButtonTapped:
            return environment
                .recipeClient
                .setFavorite(state.id, !state.isFavorite)
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect(RecipeAction.saveFavorite)

        case .nutritions:
            return .none
            
        case .saveFavorite(.success):
            state.isFavorite.toggle()
            return .none

        case .saveFavorite(.failure):
            return .none

        }
    }
)


// MARK: - View

public struct RecipeView: View {

    // MARK: - Store

    private let store: Store<Recipe, RecipeAction>


    // MARK: - Body

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    Text(viewStore.name)
                        .font(.system(size: 24, weight: .bold))
                        .padding(.horizontal)

                    GradientPhotoView(image: viewStore.image)
                        .frame(height: 260)
                        .overlay(alignment: .bottom) {
                            FavoriteBarView(isFavorite: viewStore.isFavorite)
                        }

                    RatingView(rating: viewStore.rating)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Divider()

                    Text("Steps")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal)

                    Text(viewStore.steps)
                        .font(.system(size: 14))
                        .padding()

                    Divider()

                    NutritionsView(
                        store: store.scope(
                            state: \.nutritionsState,
                            action: RecipeAction.nutritions
                        )
                    )
                    .padding(.bottom)
                }
            }
            .onAppear { viewStore.send(.onAppear) }
            .navigationBarTitleDisplayMode(.inline)
        }
    }


    // MARK: - Init

    public init(store: Store<Recipe, RecipeAction>) {
        self.store = store
    }
}
