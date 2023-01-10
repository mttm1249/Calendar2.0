//
//  StorageManager.swift
//  EventsCalendar
//
//  Created by Денис on 05.01.2023.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ event: EventModel) {
        try! realm.write {
            realm.add(event)
        }
    }
    
    static func deleteObject(_ event: EventModel) {
        try! realm.write {
            realm.delete(event)
        }
    }
    
}
