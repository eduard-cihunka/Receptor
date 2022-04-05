//
//  Line.swift
//  Receptor
//

import SwiftUI


public struct Line: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// MARK: - Preview

struct Line_Previews: PreviewProvider {
    static var previews: some View {
        Line()
            .stroke(style: .init(lineWidth: 6, lineCap: .round))
    }
}
