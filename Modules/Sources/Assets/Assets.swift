//
//  Asset.swift
//  Receptor
//

import UIKit


public enum Asset {
    public static func image(_ name: String) -> UIImage {
        if let image = UIImage(named: name, in: Bundle.swiftUIPreviewsCompatibleModule, compatibleWith: nil) {
            return image
        }
        return UIImage()
    }

    public static let placeholder = image("placeholder")
}

extension Foundation.Bundle {
    static var swiftUIPreviewsCompatibleModule: Bundle {
        final class CurrentBundleFinder {}

        let bundleNameIOS = "Modules_Assets"

        let candidates = [
            /* Bundle should be present here when the package is linked into an App. */
            Bundle.main.resourceURL,

            /* Bundle should be present here when the package is linked into a framework. */
            Bundle(for: CurrentBundleFinder.self).resourceURL,

            /* For command-line tools. */
            Bundle.main.bundleURL,

            /* Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/"). */
            Bundle(for: CurrentBundleFinder.self)
                .resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent(),
            Bundle(for: CurrentBundleFinder.self)
                .resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent(),
        ]

        for candidate in candidates {
            let bundlePathiOS = candidate?.appendingPathComponent(bundleNameIOS + ".bundle")

            if let bundle = bundlePathiOS.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        fatalError("unable to find bundle")
    }
}
