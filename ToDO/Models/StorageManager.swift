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
    
    static func saveCategoryObject(_ category: Category) {
        
        try! realm.write {
            realm.add(category)
        }
    }
    
    static func deleteCategory(_ category: Category) {
        
        try! realm.write {
            realm.delete(category)
        }
    }
    
    static func saveTaskObject(_ task: Task) {
        
        try! realm.write {
            realm.add(task)
        }
    }
    
    static func deleteTask(_ task: Task) {
        
        try! realm.write {
            realm.delete(task)
        }
    }
    
    static func saveAccountObject(_ account: Account) {
           
           try! realm.write {
               realm.add(account)
           }
       }
       
       static func deleteAccount(_ account: Account) {
           
           try! realm.write {
               realm.delete(account)
           }
       }
    
}

