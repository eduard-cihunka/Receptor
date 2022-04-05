//
//  RatingView.swift
//  Receptor
//

import SwiftUI


public struct RatingView: View {

    // MARK: - Properties

    private let rating: Int
    private let maxRating: Int


    // MARK: - Body

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .foregroundColor(index < rating ? .yellow : .gray)
            }
        }
    }

    // MARK: - Init

    public init(rating: Int, maxRatng: Int = 5) {
        self.rating = rating
        self.maxRating = maxRatng
    }
}


// MARK: - Preview

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        RatingView(rating: 3, maxRatng: 6)
    }
}
