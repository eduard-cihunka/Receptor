//
//  ProgressBar.swift
//  Receptor
//

import SwiftUI


public struct ProgressBar: View {

    // MARK: - Properties

    private var progress: Double


    // MARK: - Body

    public var body: some View {
        ZStack {
            Line()
                .stroke(style: .init(lineWidth: 6, lineCap: .round))
                .foregroundColor(.gray)

            Line()
                .trim(from: 0, to: progress)
                .stroke(style: .init(lineWidth: 6, lineCap: .round))
                .foregroundColor(.red)
        }
        .frame(height: 6)
    }


    // MARK: - Init

    public init(_ progress: Double) {
        self.progress = progress
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(0.6)
    }
}
