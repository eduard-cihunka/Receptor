//
//  NutritionsGraph.swift
//  Receptor
//

import SwiftUI
import Models
import Views


struct NutritionsGraph: View {

    // MARK: - Properties

    var nutritions: [Nutrition]


    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading) {
            Text("Nutritions")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal)

            CircleGraph(
                values: nutritions.map {
                    .init(value: $0.weight.value, color: $0.type.color)
                }
            )
            .frame(height: 400)
            .padding(8)

            VStack(alignment: .leading) {
                ForEach(nutritions) { nutrition in
                    HStack {
                        Rectangle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(nutrition.type.color)

                        Text(nutrition.type.value)

                        Spacer()

                        Text(nutrition.formattedWeight)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}


// MARK: - Preview

struct NutritionsGraphView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionsGraph(
            nutritions: [
                .init(id: UUID(), type: .fat, weight: 35),
                .init(id: UUID(), type: .fiber, weight: 25),
                .init(id: UUID(), type: .carbohydrates, weight: 45),
                .init(id: UUID(), type: .protein, weight: 15)
            ]
        )
    }
}
