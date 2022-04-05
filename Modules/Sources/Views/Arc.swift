//
//  Arc.swift
//  Receptor
//

import SwiftUI


// MARK: - Arc view

struct ArcView: View {
    var isSelected = false
    var startAngle: Double
    var endAngle: Double

    var body: some View {
        Arc(
            startAngle: startAngle,
            endAngle: endAngle,
            radiusMultiplier: isSelected ? 1 : 0.85
        )
    }
}


// MARK: - Arc shape

struct Arc: Shape, Animatable {

    // MARK: - Properties

    private var startAngle: Double
    private var endAngle: Double
    private var startAngleDegrees: Angle {
        .init(degrees: startAngle - 90)
    }
    private var endAngleDegrees: Angle {
        .init(degrees: endAngle - 90)
    }
    private var radiusMultiplier: Double

    var animatableData: Double {
        get { radiusMultiplier }
        set { radiusMultiplier = newValue }
    }


    // MARK: - Path

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.size.width, rect.size.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius * radiusMultiplier,
            startAngle: startAngleDegrees,
            endAngle: endAngleDegrees,
            clockwise: false
        )

        return path
    }


    // MARK: - Init

    init(startAngle: Double, endAngle: Double, radiusMultiplier: Double) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.radiusMultiplier = radiusMultiplier
    }
}


// MARK: - Preview

struct Arc_Previews: PreviewProvider {
    static var previews: some View {
        Arc(startAngle: 0, endAngle: 220, radiusMultiplier: 1)
    }
}
