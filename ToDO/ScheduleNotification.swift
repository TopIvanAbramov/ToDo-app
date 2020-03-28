//
//  ScheduleNotification.swift
//  ToDO
//
//  Created by Иван on 20.02.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

class ScheduleNotification {
    
    func scheduleNotification(notificationType: String) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        
        content.title = notificationType
        content.body = "This is example how to create notificationType Notifications"
        content.sound = UNNotificationSound.default
        content.badge = 1
    }
}
