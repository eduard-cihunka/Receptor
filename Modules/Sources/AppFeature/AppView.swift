//
//  AppView.swift
//  Receptor
//

import SwiftUI
import ComposableArchitecture
import RecipesFeature
import Models
import RecipeClient
import ImageClient


// MARK: - State

public struct AppState: Equatable {
    var recipesState = RecipesState()

    public init() { }
}


// MARK: - Actions

public enum AppAction {
    case onAppear
    case loadRecipes
    case recipes(RecipesAction)
    case recipesLoaded(Result<[Recipe], Failure>)
}


// MARK: - Environment

public struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var backgroundQueue: AnySchedulerOf<DispatchQueue>
    var recipeClient: RecipeClient
    var imageClient: ImageClient
    var uuid: () -> UUID

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        recipeClient: RecipeClient,
        imageClient: ImageClient,
        uuid: @escaping () -> UUID
    ) {
        self.recipeClient = recipeClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.imageClient = imageClient
        self.uuid = uuid
    }
}


// MARK: - Reducer

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    recipesReducer.pullback(
        state: \.recipesState,
        action: /AppAction.recipes,
        environment: {
            RecipesEnvironment(
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                recipeClient: $0.recipeClient,
                imageClient: $0.imageClient,
                uuid: $0.uuid
            )
        }
    ),

    Reducer { state, action, environment in
        switch action {
        case .onAppear:
            return .init(value: .loadRecipes)

        case .loadRecipes:
            state.recipesState.isLoading = true
            return environment
                .recipeClient
                .getRecipes()
                .subscribe(on: environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.recipesLoaded)

        case .recipes(.errorAlert(.tryItAgain)):
            return .init(value: .loadRecipes)

        case .recipesLoaded(.success(let recipes)):
            state.recipesState.isLoading = false
            state.recipesState.recipes = .init(uniqueElements: recipes)
            return .none

        case .recipesLoaded(.failure(let error)):
            state.recipesState.isLoading = false
            state.recipesState.alert = .errorAlertState(error.localizedDescription)
            return .none

        case .recipes:
            return .none
        }
    }
)


// MARK: - View

public struct AppView: View {

    // MARK: - Store

    private let store: Store<AppState, AppAction>


    // MARK: - Body

    public var body: some View {
        WithViewStore(store.stateless) { viewStore in
            NavigationView {
                RecipesView(
                    store: self.store.scope(
                        state: \.recipesState,
                        action: AppAction.recipes
                    )
                )
            }
            .onAppear { viewStore.send(.onAppear) }
        }
    }


    // MARK: - Init

    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }
}


// MARK: - Extensions

extension AlertState where Action == RecipesAction.ErrorAlertAction {
    static var errorAlertState: (String) -> Self = { message in
        Self(
            title: .init("Error occurred"),
            message: .init(message),
            buttons: [
                .default(.init("Cancel"), action: .send(.onAlertDismiss)),
                .default(.init("Try again"), action: .send(.tryItAgain))
            ]
        )
    }
}
