//
//  AppDelegate.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import UIKit

import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var cancellables: Set<AnyCancellable> = []
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // FIXME: Background Notification에 대응할 코드가 작성되어야 함.
        print("RECEIVED")
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // FIXME: Foreground Notification에 대응할 코드가 작성되어야 함.
        print("RECEIVED")
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        // FIXME: 더 좋은 방법 찾아보기
        let networkService = URLSessionNetworkService()
        let persistenceService = UserDefaultsPersistenceService()
        let userRepository: UserRepository = UserRepository(persistenceService: persistenceService, networkService: networkService)
        let fcmTokenRepository: FCMTokenRepository = FCMTokenRepository(urlSessionNetworkService: networkService)
        let getMyIdUseCase: GetMyIdUseCase = GetMyIdUseCase(userRepository: userRepository)
        let fcmTokenUseCase: FCMTokenUseCase = FCMTokenUseCase(fcmTokenRepository: fcmTokenRepository)
        
        getMyIdUseCase.getMyId()
            .compactMap { $0 }
            .sink { [weak self] myId in
                guard let self = self else { return }
                fcmTokenUseCase.setToken(for: myId, with: token)
                    .sink { completion in
                        guard case .failure(let error) = completion else { return }
                        print(error.localizedDescription)
                    } receiveValue: { token in
                        print("SUCCESS: \(token)")
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
    }
}
