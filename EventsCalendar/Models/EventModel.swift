//
//  EventModel.swift
//  EventList
//
//  Created by Денис on 17.01.2023.
//

import Foundation

struct EventModel {
    var name: String?
    var eventText: String?
    var isCompleted: Bool?
    var eventDate: Date?
    var priorityID: Int?
    
    var eventNotificationDate: Date?
    var eventNotificationID = UUID()
    var eventWithNotification: Bool?
}
