//
//  Note.swift
//  ToDO
//
//  Created by Иван on 18.02.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

import RealmSwift

class Category: Object {
    
    
//    @objc dynamic var priority = 0
//    @objc dynamic var creationTime = 0.0
//    @objc dynamic var timeInterval = 0.0
//    @objc dynamic var done = false
    
    @objc dynamic var id = ""
    @objc dynamic var userEmail = ""
    @objc dynamic var categoryName = ""
    @objc dynamic var emoji = ""
    
    convenience init(id : String, userEmail : String, categoryName: String, emoji: String) {
        self.init()
        self.id = id
        self.userEmail = userEmail
        self.categoryName = categoryName
        self.emoji = emoji
    }
    
//    convenience init(id : String, text: String, priority: Int, creationTime: Double, timeInterval : Double, done : Bool, userEmail : String) {
//        self.init()
//        self.id = id
//        self.text = text
//        self.priority = priority
//        self.creationTime = creationTime
//        self.timeInterval = timeInterval
//        self.done = done
//        self.userEmail = userEmail
//    }
}
