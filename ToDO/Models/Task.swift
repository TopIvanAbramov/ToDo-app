//
//  Task.swift
//  ToDo
//
//  Created by Иван Абрамов on 21.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//
import UIKit

import RealmSwift

class Task: Object {
    
    
//    @objc dynamic var priority = 0
//    @objc dynamic var creationTime = 0.0
//    @objc dynamic var timeInterval = 0.0
//    @objc dynamic var done = false
    
    @objc dynamic var categoryid = ""
    @objc dynamic var id = ""
    @objc dynamic var text = ""
    @objc dynamic var userEmail = ""
     @objc dynamic var done = false
    
    convenience init(categoryid: String, id : String, text: String, userEmail : String, done: Bool) {
        self.init()
        self.categoryid = categoryid
        self.id = id
        self.text = text
        self.userEmail = userEmail
        self.done = done
    }
}
