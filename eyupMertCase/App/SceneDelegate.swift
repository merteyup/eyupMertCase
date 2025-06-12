//
//  SceneDelegate.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import UIKit
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let container = try! ModelContainer(for: VisitPoint.self)

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let context = container.mainContext
        let rootVC = MapViewRouter.make(context: context)
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        LocationManager.shared.willEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("Significant Location Changes takibi")
        LocationManager.shared.didEnterBackground()
    }
}

