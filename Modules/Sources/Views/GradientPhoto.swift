//
//  GradientPhoto.swift
//  Receptor
//

import SwiftUI
import Assets


public struct GradientPhotoView: View {

    // MARK: - Properties

    private var image: UIImage?


    // MARK: - Body

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Image(uiImage: image ?? Asset.placeholder)
                    .resizable()
                    .scaledToFill()
                    .frame(height: geometry.size.height)
                    .clipped()
                
                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(0.4)],
                    startPoint: .init(x: 0, y: 0),
                    endPoint: .init(x: 0, y: 1)
                )
            }
        }
    }


    // MARK: - Init

    public init(image: UIImage?) {
        self.image = image
    }
}


// MARK: - Preview

struct GradientPhoto_Previews: PreviewProvider {
    static var previews: some View {
        GradientPhotoView(image: nil)
    }
}
