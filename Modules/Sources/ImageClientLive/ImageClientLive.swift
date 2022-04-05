//
//  ImageClient.swift
//  Receptor
//

import ImageClient
import FirebaseStorage
import FirebaseStorageSwift
import UIKit


extension ImageClient {

    public static var live: Self {
        let storage = Storage.storage()

        return ImageClient(
            saveImage: { image, id in
                .future { promise in
                    Task {
                        do {
                            let storageReference = storage.reference().child("images/\(id).jpg")
                            let data = image.jpegData(compressionQuality: 0.2)

                            let metadata = StorageMetadata()
                            metadata.contentType = "image/jpg"

                            guard let data = data else {
                                promise(.failure(.init(errorDescription: "Failed to create data from image")))
                                return
                            }

                            _ = try await storageReference.putDataAsync(data, metadata: metadata)
                            promise(.success(image))
                        } catch {
                            promise(.failure(.init(errorDescription: error.localizedDescription)))
                        }
                    }
                }
            },
            getImage: { id in
                .future { promise in
                    let storageReference = storage.reference().child("images/\(id).jpg")
                    storageReference.getData(maxSize: 1 * 1024 * 1024) { data, _ in
                        guard let data = data, let image = UIImage(data: data) else {
                            return
                        }

                        promise(.success(image))
                    }
                }
            }
        )
    }
}
