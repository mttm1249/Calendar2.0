//
//  CloudManager.swift
//  EventsCalendar
//
//  Created by Денис on 13.01.2023.
//

import UIKit
import CloudKit
import RealmSwift

class CloudManager {
    
    private static let privateCloudDatabase = CKContainer(identifier: CloudConfig.containerIdentifier).privateCloudDatabase
    private static var records: [CKRecord] = []

    static func saveDataToCloud(event: EventModel, closure: @escaping (String) -> ()) {
        let record = CKRecord(recordType: "EventModel")
        record.setValue(event.eventID, forKey: "eventID")
        record.setValue(event.name, forKey: "name")
        record.setValue(event.eventText, forKey: "eventText")
        record.setValue(event.isCompleted, forKey: "isCompleted")
        record.setValue(event.eventDate, forKey: "eventDate")
        record.setValue(event.priorityID, forKey: "priorityID")
        
        record.setValue(event.eventNotificationDate, forKey: "eventNotificationDate")
        record.setValue(event.eventNotificationID, forKey: "eventNotificationID")
        record.setValue(event.eventWithNotification, forKey: "eventWithNotification")
        
        privateCloudDatabase.save(record) { (newRecord, error) in
            if let error = error { print(error); return }
            if let newRecord = newRecord {
                closure(newRecord.recordID.recordName)
            }
        }
    }
    
    static func fetchDataFromCloud(events: Results<EventModel>, closure: @escaping (EventModel) -> ()) {
        let query = CKQuery(recordType: "EventModel", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        
        let queryOperation = CKQueryOperation(query: query)

                queryOperation.desiredKeys = ["recordID", "eventID", "name", "eventText",
                                              "isCompleted", "eventDate", "priorityID",
                                              "eventNotificationDate",
                                              "eventNotificationID",
                                              "eventWithNotification"
                ]
        queryOperation.resultsLimit = 10
        queryOperation.queuePriority = .veryHigh
        
        queryOperation.recordFetchedBlock = { record in
            
            self.records.append(record)
            let newEvent = EventModel(record: record)
            
            DispatchQueue.main.async {
                if newCloudRecordIsAvailable(events: events, eventID: newEvent.eventID) {
                    closure(newEvent)
                }
            }
        }
        
        queryOperation.queryCompletionBlock = { cursor, error in
            if let error = error { print(error.localizedDescription); return }
            guard let cursor = cursor else { return }
            
            let secondQueryOperation = CKQueryOperation(cursor: cursor)
            secondQueryOperation.recordFetchedBlock = { record in
                self.records.append(record)
                let newRecord = EventModel(record: record)
                
                DispatchQueue.main.async {
                    if newCloudRecordIsAvailable(events: events, eventID: newRecord.eventID) {
                        closure(newRecord)
                    }
                }
            }
            secondQueryOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
            privateCloudDatabase.add(secondQueryOperation)
        }
        
        privateCloudDatabase.add(queryOperation)
    }
    
    static func updateCloudData(event: EventModel) {
        let recordID = CKRecord.ID(recordName: event.recordID)
        
        privateCloudDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let record = record, error == nil {
                DispatchQueue.main.async {
                    record.setValue(event.name, forKey: "name")
                    record.setValue(event.eventText, forKey: "eventText")
                    record.setValue(event.isCompleted, forKey: "isCompleted")
                    record.setValue(event.eventDate, forKey: "eventDate")
                    record.setValue(event.priorityID, forKey: "priorityID")
                    
                    record.setValue(event.eventNotificationDate, forKey: "eventNotificationDate")
                    record.setValue(event.eventNotificationID, forKey: "eventNotificationID")
                    record.setValue(event.eventWithNotification, forKey: "eventWithNotification")
                    privateCloudDatabase.save(record, completionHandler: { (_, error) in
                        if let error = error { print(error.localizedDescription); return }
                    })
                }
            }
        }
    }
    
    static func deleteRecord(recordID: String) {
        let query = CKQuery(recordType: "EventModel", predicate: NSPredicate(value: true))
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["recordID"]
        queryOperation.queuePriority = .veryHigh
        
        queryOperation.recordFetchedBlock = { record in
            if record.recordID.recordName == recordID {
                privateCloudDatabase.delete(withRecordID: record.recordID, completionHandler: { (_, error) in
                    if let error = error { print(error); return }
                })
            }
            
            queryOperation.queryCompletionBlock = { _, error in
                if let error = error { print(error); return }
            }
        }
        
        privateCloudDatabase.add(queryOperation)
    }
        
    private static func newCloudRecordIsAvailable(events: Results<EventModel>, eventID: String) -> Bool {
        for event in events {
            if event.eventID == eventID {
                return false
            }
        }
        return true
    }
}

 


