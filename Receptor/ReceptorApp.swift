//
//  ReceptorApp.swift
//  Receptor
//
//  Created by Eduard Cihuňka on 03.04.2022.
//

import SwiftUI
import AppFeature
import ComposableArchitecture
import Firebase
import RecipeClientLive
import ImageClientLive


// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Store

    // Store is here, in case we want send some actions from appDelegate
    var store: Store<AppState, AppAction>!


    // MARK: - UIApplicationDelegate

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Firebase must be configured before initializing Store, if not app will crash
        FirebaseApp.configure()
        store = Store(
            initialState: .init(),
            reducer: appReducer,
            environment: .live
        )
        return true
    }
}


@main
struct ReceptorApp: App {

    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: self.appDelegate.store)
        }
    }
}

// MARK: - Extensions


extension AppEnvironment {
    static let live = Self(
        mainQueue: .main,
        backgroundQueue: DispatchQueue(label: "background-queue").eraseToAnyScheduler(),
        recipeClient: .live,
        imageClient: .live,
        uuid: { UUID() }
    )
}
