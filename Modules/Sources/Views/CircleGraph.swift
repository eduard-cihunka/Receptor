//
//  CircleGraph.swift
//  Receptor
//

import SwiftUI

public struct CircleGraph: View {

    public struct GraphValue {
        public var value: Double
        public var color: Color

        public init(value: Double, color: Color) {
            self.value = value
            self.color = color
        }
    }

    // MARK: - Properties

    @State private var isSelected: Int?

    private var values: [Double]
    private var colors: [Color]


    // MARK: - Body

    public var body: some View {
        ZStack {
            ForEach(0..<values.count - 1, id: \.self) { index in
                ArcView(
                    isSelected: isSelected == index,
                    startAngle: values[index],
                    endAngle: values[index + 1]
                )
                .foregroundColor(colors[index])
                .onTapGesture {
                    withAnimation {
                        if isSelected == index {
                            isSelected = .none
                        } else {
                            isSelected = index
                        }
                    }
                }
            }
            Circle()
                .scale(0.6)
                .foregroundColor(.white)
        }
    }


    // MARK: - Init

    public init(values: [GraphValue]) {
        let valuesSum = values.reduce(0, { $0 + $1.value })
        let oneDegreeValue = 360 / valuesSum

        var updatedValues: [Double] = [0]

        for index in 0..<values.count {
            updatedValues.append(updatedValues[index] + values[index].value * oneDegreeValue)
        }

        self.values = updatedValues
        self.colors = values.map { $0.color }
    }
}


// MARK: - Preview

struct CircleGraph_Previews: PreviewProvider {
    static var previews: some View {
        CircleGraph(
            values: [
                .init(value: 10, color: .red),
                .init(value: 25, color: .blue)
            ]
        )
    }
}
