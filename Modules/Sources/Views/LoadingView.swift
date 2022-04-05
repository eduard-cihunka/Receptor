//
//  SwiftUIView.swift
//  Receptor
//

import SwiftUI

public struct LoadingView<Content: View>: View {
    let isLoading: Bool
    let loadingTitle: String
    let content: Content

    public var body: some View {
        ZStack {
            content

            if isLoading {
                ProgressView(loadingTitle)
                    .progressViewStyle(CustomProgressViewStyle())
                Color.white.opacity(0.001)
            }
        }
    }

    public init(
        isLoading: Bool,
        loadingTitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.isLoading = isLoading
        self.loadingTitle = loadingTitle
        self.content = content()
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(
            isLoading: true,
            loadingTitle: "Loading recipes"
        ) {
            VStack {
                Button("Recipe", action: {  })
                Spacer()
            }
        }
    }
}
