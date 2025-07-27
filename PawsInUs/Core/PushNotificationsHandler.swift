//
//  PushNotificationsHandler.swift
//  Pawsinus
//
//  Created by Alexey Naumov on 26.04.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import UserNotifications

protocol PushNotificationsHandler { }

final class RealPushNotificationsHandler: NSObject, PushNotificationsHandler, @unchecked Sendable {
    
    private let deepLinksHandler: DeepLinksHandler
    
    init(deepLinksHandler: DeepLinksHandler) {
        self.deepLinksHandler = deepLinksHandler
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension RealPushNotificationsHandler: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo: userInfo, completionHandler: completionHandler)
    }
    
    func handleNotification(userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        guard let payload = userInfo["aps"] as? [AnyHashable: Any] else {
            completionHandler()
            return
        }
        
        // Handle different notification types
        if let dogID = payload["dogID"] as? String {
            let handler = deepLinksHandler
            Task { @MainActor in
                handler.open(deepLink: .showDog(dogID: dogID))
            }
            completionHandler()
        } else if let matchID = payload["matchID"] as? String {
            let handler = deepLinksHandler
            Task { @MainActor in
                handler.open(deepLink: .showMatch(matchID: matchID))
            }
            completionHandler()
        } else {
            completionHandler()
        }
    }
}
