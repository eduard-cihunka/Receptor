//
//  RecipeCard.swift
//  Receptor
//

import SwiftUI
import Models
import RecipeFeature
import Views
import ImageClient
import ComposableArchitecture


// MARK: - View

struct RecipeCard: View {

    // MARK: - Store

    let store: Store<Recipe, RecipeAction>


    // MARK: - Body

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                GradientPhotoView(image: viewStore.image)
                    .frame(height: 220)
                    .overlay(alignment: .bottom) {
                        FavoriteBarView(
                            isFavorite: viewStore.isFavorite,
                            onFavoriteButtonTapped: { viewStore.send(.favoriteButtonTapped) }
                        )
                    }

                VStack(alignment: .leading) {
                    Text(viewStore.name)
                        .font(.system(size: 16, weight: .bold))

                    Text(viewStore.shortDescription)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.leading)
                }
                .foregroundColor(.black)
                .padding()
            }
            .onAppear { viewStore.send(.onAppear) }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 6)
        }
    }
}


// MARK: - Preview

struct RecipeCard_Previews: PreviewProvider {
    static var previews: some View {
        RecipeCard(
            store: .init(
                initialState: .mock,
                reducer: recipeReducer,
                environment: .init(
                    mainQueue: .immediate,
                    backgroundQueue: .immediate,
                    recipeClient: .mock,
                    imageClient: .mock
                )
            )
        )
    }
}
