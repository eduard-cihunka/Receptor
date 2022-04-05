//
//  RecipesView.swift
//  Receptor
//

import SwiftUI
import IdentifiedCollections
import ComposableArchitecture
import AddRecipeFeature
import RecipeFeature
import Views
import Models
import RecipeClient
import ImageClient


// MARK: - State

public struct RecipesState: Equatable {

    public enum Filter: String, CaseIterable {
        case all
        case favorite
        case vegan

        var title: String { rawValue.capitalized }
    }

    public var recipes: IdentifiedArrayOf<Recipe> = []
    public var alert: AlertState<RecipesAction.ErrorAlertAction>?
    public var isLoading = false

    var filteredRecipes: IdentifiedArrayOf<Recipe> {
        switch filter {
        case .all: return recipes
        case .favorite: return recipes.filter(\.isFavorite)
        case .vegan: return recipes.filter { $0.category == .vegan }
        }
    }
    var filter: Filter = .all
    var newRecipe: AddRecipeState?
    var isNewRecipePresented: Bool { newRecipe != nil }

    public init() {}
}

extension RecipesState {
    public var addRecipe: AddRecipeState? {
        get {
            .init(recipes: recipes, state: newRecipe)
        }
        set {
            self.recipes = newValue?.recipes ?? self.recipes
            self.newRecipe = newValue
        }
    }
}


// MARK: - Actions

public enum RecipesAction {
    case addRecipe(AddRecipeAction)
    case recipe(id: Recipe.ID, action: RecipeAction)
    case addRecipeButtonTapped
    case dismissSheet
    case errorAlert(ErrorAlertAction)
    case selectFilter(RecipesState.Filter)

    public enum ErrorAlertAction {
        case onAlertDismiss
        case tryItAgain
    }
}


// MARK: - Environment

public struct RecipesEnvironment {

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
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.recipeClient = recipeClient
        self.imageClient = imageClient
        self.uuid = uuid
    }
}


// MARK: - Reducer

public let recipesReducer = Reducer<RecipesState, RecipesAction, RecipesEnvironment>.combine(
    addRecipeReducer
        .optional()
        .pullback(
            state: \RecipesState.addRecipe,
            action: /RecipesAction.addRecipe,
            environment: {
                AddRecipeEnvironment(
                    mainQueue: $0.mainQueue,
                    backgroundQueue: $0.backgroundQueue,
                    recipeClient: $0.recipeClient,
                    imageClient: $0.imageClient,
                    uuid: $0.uuid
                )
            }
        ),

    recipeReducer.forEach(
        state: \.recipes,
        action: /RecipesAction.recipe(id:action:),
        environment: {
            RecipeEnvironment(
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                recipeClient: $0.recipeClient,
                imageClient: $0.imageClient
            )
        }
    ),

    Reducer { state, action, _ in
        switch action {
        case .addRecipe:
            return .none

        case .recipe:
            return .none

        case .addRecipeButtonTapped:
            state.newRecipe = .init()
            return .none

        case .dismissSheet:
            state.newRecipe = nil
            return .none

        case .errorAlert(.onAlertDismiss):
            state.alert = nil
            return .none

        case .errorAlert(.tryItAgain):
            return .none

        case .selectFilter(let filter):
            state.filter = filter
            return .none
        }
    }
)


// MARK: - View

public struct RecipesView: View {

    // MARK: - Store

    let store: Store<RecipesState, RecipesAction>


    // MARK: - Body

    public var body: some View {
        WithViewStore(store) { viewStore in
            LoadingView(isLoading: viewStore.isLoading, loadingTitle: "Loading recipes") {
                VStack {
                    WithViewStore(store.scope(state: \.filter)) { filterStore in
                        Picker(
                            "Tab",
                            selection: filterStore.binding(send: RecipesAction.selectFilter).animation()
                        ) {
                            ForEach(RecipesState.Filter.allCases, id: \.self) {
                                Text($0.title).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                    }

                    ScrollView(.vertical) {
                        LazyVGrid(columns: [.init(.adaptive(minimum: .infinity, maximum: .infinity), spacing: 10)]) {
                            ForEachStore(
                                store.scope(
                                    state: \.filteredRecipes,
                                    action: RecipesAction.recipe(id:action:)
                                )
                            ) { childStore in
                                NavigationLink(
                                    destination: RecipeView(store: childStore)
                                ) {
                                    RecipeCard(store: childStore)
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar { Button("Add", action: { viewStore.send(.addRecipeButtonTapped) }) }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isNewRecipePresented,
                    send: RecipesAction.dismissSheet
                )
            ) {
                NavigationView {
                    IfLetStore(
                        self.store.scope(
                            state: \RecipesState.newRecipe,
                            action: RecipesAction.addRecipe
                        ),
                        then: AddRecipeView.init(store:)
                    )
                }
            }
            .alert(
                self.store.scope(state: \.alert, action: RecipesAction.errorAlert),
                dismiss: .onAlertDismiss
            )
        }
    }


    // MARK: - Init

    public init(store: Store<RecipesState, RecipesAction>) {
        self.store = store
    }
}
