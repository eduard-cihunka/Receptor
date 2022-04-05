//
//  ImagePicker.swift
//  Receptor
//

import PhotosUI
import SwiftUI

public struct ImagePicker: UIViewControllerRepresentable {
    @Binding private var image: UIImage?

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        public init(_ parent: ImagePicker) {
            self.parent = parent
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider else {
                self.parent.image = nil
                return
            }
            guard provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }

    public init(image: Binding<UIImage?>) {
        self._image = image
    }
}
