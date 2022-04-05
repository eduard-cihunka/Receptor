//
//  FavoriteBarView.swift
//  Receptor
//

import SwiftUI


public struct FavoriteBarView: View {

    // MARK: - Properties

    private var isFavorite: Bool
    private var onFavoriteButtonTapped: (() -> Void)?


    // MARK: - Body

    public var body: some View {
        HStack {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 20, weight: .bold))
                .onTapGesture { onFavoriteButtonTapped?() }

            Spacer()
        }
        .foregroundColor(.white)
        .padding()
    }


    // MARK: - Init

    public init(
        isFavorite: Bool,
        onFavoriteButtonTapped: (() -> Void)? = nil
    ) {
        self.isFavorite = isFavorite
        self.onFavoriteButtonTapped = onFavoriteButtonTapped
    }
}


// MARK: - Preview

struct PhotoBarView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteBarView(isFavorite: true)
    }
}
