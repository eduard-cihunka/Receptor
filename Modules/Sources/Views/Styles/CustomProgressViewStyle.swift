//
//  SwiftUIView.swift
//  
//
//  Created by Eduard Cihuňka on 10.04.2022.
//

import SwiftUI

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.2))
            )
    }
}
