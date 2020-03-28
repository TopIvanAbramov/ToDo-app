//
//  Note.swift
//  ToDO
//
//  Created by Иван on 18.02.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

import RealmSwift

class Note: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var text = ""
    @objc dynamic var priority = 0
    @objc dynamic var creationTime = 0.0
    @objc dynamic var timeInterval = 0.0
    @objc dynamic var done = false
    @objc dynamic var userEmail = ""
    
    
    convenience init(id : String, text: String, priority: Int, creationTime: Double, timeInterval : Double, done : Bool, userEmail : String) {
        self.init()
        self.id = id
        self.text = text
        self.priority = priority
        self.creationTime = creationTime
        self.timeInterval = timeInterval
        self.done = done
        self.userEmail = userEmail
    }
}
