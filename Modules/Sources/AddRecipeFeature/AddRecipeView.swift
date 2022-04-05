//
//  AddRecipeView.swift
//  Receptor
//

import SwiftUI
import ComposableArchitecture
import Models
import Views
import RecipeClient
import ImageClient
import Combine


// MARK: - State

public struct AddRecipeState: Equatable {

    struct Form: Equatable {
        @BindableState var title = ""
        @BindableState var description = ""
        @BindableState var steps = ""
        @BindableState var category: Recipe.Category = .meat
        @BindableState var isFavorite  = false
        @BindableState var focusedField: Field?
        var nutritionsState = NutritionPickerState()
        var imagePickerState = ImagePickerViewState()

        enum Field: String, Hashable {
            case title, description, steps, weight
        }
    }

    public var recipes: IdentifiedArrayOf<Recipe> = []

    var form = Form()
    var isSavingRecipe = false
    var isPresented = true
    var addRecipeAlert: AlertState<AddRecipeAction.AddRecipeAlert>?
    var recipeToSave: Recipe?

    public init() {}
}

extension AddRecipeState {
    var imageState: ImagePickerViewState {
        get { form.imagePickerState }
        set { form.imagePickerState = newValue }
    }
}

extension AddRecipeState {
    var progress: Double {
        var count: Double = 0
        if !form.title.isEmpty { count += 1 }
        if !form.description.isEmpty { count += 1 }
        if !form.steps.isEmpty { count += 1 }
        if !form.nutritionsState.nutritions.isEmpty { count += 1 }
        if imageState.image != nil { count += 1 }

        return count == 0 ? count : count / 5
    }
    var isSaveDisabled: Bool {
        progress != 1
    }
}

extension AddRecipeState {

    public init(recipes: IdentifiedArrayOf<Recipe> = [], state: AddRecipeState?) {
        self.recipes = recipes
        self.form = state?.form ?? .init()
        self.recipeToSave = state?.recipeToSave
    }
}


// MARK: - Actions

public enum AddRecipeAction: BindableAction, Equatable {

    case binding(BindingAction<AddRecipeState>)
    case recipeSaved(Result<Recipe, Failure>)
    case saveButtonTapped
    case cancelButtonTapped
    case nutritionPicker(NutritionPickerAction)
    case imagePicker(ImagePickerAction)
    case addRecipeAlert(AddRecipeAlert)
    case onCloseKeyboard

    public enum AddRecipeAlert: Equatable {
        case tryItAgain
        case onDismiss
    }
}


// MARK: - Environment

public struct AddRecipeEnvironment {
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

public let addRecipeReducer = Reducer<AddRecipeState, AddRecipeAction, AddRecipeEnvironment>.combine(
    nutritionPickerReducer.pullback(
        state: \.form.nutritionsState,
        action: /AddRecipeAction.nutritionPicker,
        environment: { NutritionPickerEnvironment(uuid: $0.uuid) }
    ),
    imagePickerReducer.pullback(
        state: \.imageState,
        action: /AddRecipeAction.imagePicker,
        environment: { _ in () }
    ),

    Reducer { state, action, environment in
        switch action {
        case .binding:
            return .none

        case .saveButtonTapped:
            guard let image = state.imageState.image else { return .none }
            let recipe: Recipe
            if let savedRecipe = state.recipeToSave {
                recipe = savedRecipe
            } else {
                let id = environment.uuid()
                recipe = Recipe.map(from: state, id: id, image: image)
                state.recipeToSave = recipe
            }

            state.isSavingRecipe = true

            return Publishers.Zip(
                environment
                    .recipeClient
                    .saveRecipe(recipe)
                    .eraseToAnyPublisher(),
                environment
                    .imageClient
                    .saveImage(image, recipe.id)
                    .eraseToAnyPublisher()
            )
            .subscribe(on: environment.backgroundQueue)
            .receive(on: environment.mainQueue)
            .map { $0.0 }
            .catchToEffect(AddRecipeAction.recipeSaved)

        case .cancelButtonTapped:
            state.isPresented = false
            return .none

        case .nutritionPicker:
            return .none

        case .recipeSaved(.success(let recipe)):
            state.isSavingRecipe = false
            state.recipes.append(recipe)
            state.recipeToSave = nil
            state.isPresented = false
            return .none

        case .recipeSaved(.failure(let error)):
            state.isSavingRecipe = false
            state.addRecipeAlert = .errorAlertState(error.localizedDescription)
            return .none

        case .imagePicker:
            return .none

        case .addRecipeAlert(.tryItAgain):
            return Effect(value: .saveButtonTapped)

        case .addRecipeAlert(.onDismiss):
            state.addRecipeAlert = nil
            return .none

        case .onCloseKeyboard:
            state.form.focusedField = nil
            return .none

        }
    }
)
    .binding()


// MARK: - View

public struct AddRecipeView: View {

    // MARK: - Properties

    @Environment(\.presentationMode) var presentationMode
    @FocusState var focusedField: AddRecipeState.Form.Field?
    private let store: Store<AddRecipeState, AddRecipeAction>


    // MARK: - Body

    public var body: some View {
        WithViewStore(store) { viewStore in
            LoadingView(
                isLoading: viewStore.isSavingRecipe,
                loadingTitle: "Saving Recipe"
            ) {
                VStack {
                    Form {
                        Section("New Recipe") {
                            TextField("Title", text: viewStore.binding(\.form.$title))
                                .focused($focusedField, equals: .title)

                            TextField("Description", text: viewStore.binding(\.form.$description))
                                .focused($focusedField, equals: .description)
                        }

                        Section("Pick Image") {
                            ImagePickerView(
                                store: store.scope(
                                    state: \.imageState,
                                    action: AddRecipeAction.imagePicker
                                )
                            )
                        }

                        Section("Steps") {
                            TextEditor(text: viewStore.binding(\.form.$steps))
                                .focused($focusedField, equals: .steps)
                        }

                        Section {
                            Picker(
                                "Category",
                                selection: viewStore.binding(\.form.$category)
                            ) {
                                ForEach(Recipe.Category.allCases, id: \.self) { category in
                                    Text(category.name).tag(category)
                                }
                            }

                            Toggle("Favorite", isOn: viewStore.binding(\.form.$isFavorite))
                        }

                        NutritionPickerView(
                            store: store.scope(
                                state: \.form.nutritionsState,
                                action: AddRecipeAction.nutritionPicker
                            )
                        )
                        .focused($focusedField, equals: .weight)

                        Section {
                            Button("Save") { viewStore.send(.saveButtonTapped) }
                                .disabled(viewStore.isSaveDisabled)
                        }
                    }
                    .onChange(of: viewStore.isPresented) { isPresented in
                        if !isPresented {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .synchronize(viewStore.binding(\.form.$focusedField), self.$focusedField)
                }
            }
            .alert(
                self.store.scope(
                    state: \.addRecipeAlert,
                    action: AddRecipeAction.addRecipeAlert
                ),
                dismiss: .onDismiss
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ProgressBar(viewStore.progress)
                        .animation(.easeOut, value: viewStore.state)
                }
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Close", action: { viewStore.send(.onCloseKeyboard) })
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }


    // MARK: - Init

    public init(store: Store<AddRecipeState, AddRecipeAction>) {
        self.store = store
    }
}


// MARK: - Preview

struct EditRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddRecipeView(
                store: Store(
                    initialState: AddRecipeState(),
                    reducer: addRecipeReducer,
                    environment: .init(
                        mainQueue: .immediate,
                        backgroundQueue: .immediate,
                        recipeClient: .mock,
                        imageClient: .mock,
                        uuid: { UUID() }
                    )
                )
            )
        }
    }
}


// MARK: - Extensions

extension Recipe {
    static func map(from state: AddRecipeState, id: UUID, image: UIImage?) -> Self {
        Self(
            id: id,
            image: image,
            name: state.form.title,
            shortDescription: state.form.description,
            steps: state.form.steps,
            isFavorite: state.form.isFavorite,
            rating: 0,
            category: state.form.category,
            nutritions: state.form.nutritionsState.nutritions.elements
        )
    }
}

extension AlertState where Action == AddRecipeAction.AddRecipeAlert {
    static var errorAlertState: (String) -> Self = { message in
        Self(
            title: .init("Error occurred"),
            message: .init(message),
            buttons: [
                .default(.init("Cancel"), action: .send(.onDismiss)),
                .default(.init("Try again"), action: .send(.tryItAgain))
            ]
        )
    }
}

extension View {
    func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}
