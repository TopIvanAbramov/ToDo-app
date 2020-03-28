//
//  StorageManager.swift
//  ToDO
//
//  Created by Иван on 18.02.2020.
//  Copyright © 2020 Ivan Abramov. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ note: Note) {
        
        try! realm.write {
            realm.add(note)
        }
    }
    
    static func deleteObject(_ note: Note) {
        
        try! realm.write {
            realm.delete(note)
        }
    }
}

