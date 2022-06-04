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
        
        UserDefaults.standard.register(
            defaults: [
                UserDefaults.Keys.globalFont: FontType.dovemayo.name,
                UserDefaults.Keys.pushNotificationState: true
            ]
        )
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // Called when APNs token is updated
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    // Called when user taps the notification banner
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let data = response.notification.request.content.userInfo
        
        if let event = data[PushMessageEntity.DataKey.event] as? String,
           let notification = PushMessageEntity.Notifications.dict[event] {
            NotificationCenter.default.post(name: notification, object: self)
        }
    }
}

extension AppDelegate: MessagingDelegate {
    // Called when fcm token is updated
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        FCMTokenRepository.shared.currentFcmToken = fcmToken
    }
}
