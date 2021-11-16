//
//  SceneDelegate.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: AppCoordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        UIFont.overrideInitialize()

        let navigationController = UINavigationController()
        
        self.coordinator = AppCoordinator(presenter: navigationController)
        self.coordinator?.start()
        
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
}
