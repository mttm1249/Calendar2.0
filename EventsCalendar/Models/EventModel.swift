//
//  EventModel.swift
//  EventsCalendar
//
//  Created by Денис on 06.01.2023.
//

import RealmSwift
import CloudKit
import UIKit

class EventModel: Object {
    @Persisted var recordID = ""
    @Persisted var eventID = UUID().uuidString
    @Persisted var name: String?
    @Persisted var eventText: String?
    @Persisted var isCompleted: Bool?
    @Persisted var eventDate: Date?
    @Persisted var priorityID: Int?
    
    @Persisted var eventNotificationDate: Date!
    @Persisted var eventNotificationID = UUID().uuidString
    @Persisted var eventWithNotification: Bool!
    
    @Persisted var savedWithInternetConnetion: Bool!

    convenience init(name: String,
                     eventText: String?,
                     isCompleted: Bool?,
                     eventDate: Date?,
                     priorityID: Int?,
                     eventNotificationDate: Date!,
                     eventNotificationID: String!,
                     eventWithNotification: Bool!)
    {
        self.init()
        self.name = name
        self.eventText = eventText
        self.isCompleted = isCompleted
        self.eventDate = eventDate
        self.priorityID = priorityID
        
        self.eventNotificationDate = eventNotificationDate
        self.eventNotificationID = eventNotificationID
        self.eventWithNotification = eventWithNotification
    }
    
    convenience init(record: CKRecord) {
        self.init()
        self.eventID = record.value(forKey: "eventID") as! String
        self.recordID = record.recordID.recordName
        self.name = record.value(forKey: "name") as? String
        self.eventText = record.value(forKey: "eventText") as? String
        self.isCompleted = record.value(forKey: "isCompleted") as? Bool
        self.eventDate = record.value(forKey: "eventDate") as? Date
        self.priorityID = record.value(forKey: "priorityID") as? Int
        
        self.eventNotificationDate = record.value(forKey: "eventNotificationDate") as? Date
        self.eventNotificationID = record.value(forKey: "eventNotificationID") as! String
        self.eventWithNotification = record.value(forKey: "eventWithNotification") as? Bool
    }
    
    static override func primaryKey() -> String? {
        return "eventID"
    }
}
