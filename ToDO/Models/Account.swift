//
//  Account.swift
//  ToDo
//
//  Created by Иван Абрамов on 22.05.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import UIKit

import RealmSwift

class Account: Object {
    
    
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var surname = ""
    @objc dynamic var userEmail = ""
    @objc dynamic var password = ""
    @objc dynamic var image : Data?
    
    convenience init(id: String, name : String, surname: String, userEmail : String, password: String,  image: Data) {
        self.init()
        self.id = id
        self.name = name
        self.surname = surname
        self.userEmail = userEmail
        self.password = password
        self.image = image
    }
}


