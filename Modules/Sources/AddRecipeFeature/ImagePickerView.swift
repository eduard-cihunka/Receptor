//
//  ImagePickerView.swift
//  Receptor
//

import SwiftUI
import ComposableArchitecture
import Views


// MARK: - State

public struct ImagePickerViewState: Equatable {
    var image: UIImage?
    var isImagePickerPresented = false
}


// MARK: - Actions

public enum ImagePickerAction: Equatable {
    case setImage(image: UIImage?)
    case showImagePicker(isPresented: Bool)
    case removeImage
}


// MARK: - Reducer

let imagePickerReducer = Reducer<ImagePickerViewState, ImagePickerAction, Void> { state, action, _ in
    switch action {
    case .showImagePicker(true):
        state.isImagePickerPresented = true
        return .none

    case .showImagePicker(false):
        state.isImagePickerPresented = false
        return .none

    case .setImage(let image):
        state.image = image
        return Effect(value: .showImagePicker(isPresented: false))

    case .removeImage:
        state.image = nil
        return .none

    }
}


// MARK: - View

struct ImagePickerView: View {
    let store: Store<ImagePickerViewState, ImagePickerAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Group {
                if let image = viewStore.image {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(height: 200)

                            Button(action: { viewStore.send(.removeImage) }) {
                                Image(systemName: "xmark")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                        }
                        .cornerRadius(8)
                        .padding(.vertical, 8)

                } else {
                    Button {
                        viewStore.send(.showImagePicker(isPresented: true))
                    } label: {
                        Text("Add picture")
                    }
                }
            }
            .fullScreenCover(
                isPresented: viewStore.binding(
                    get: \.isImagePickerPresented,
                    send: ImagePickerAction.showImagePicker(isPresented:)
                )
            ) {
                ImagePicker(
                    image: viewStore.binding(
                        get: \.image,
                        send: ImagePickerAction.setImage
                    )
                )
            }
        }
    }
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(
            store: .init(
                initialState: .init(),
                reducer: imagePickerReducer,
                environment: ()
            )
        )
    }
}
