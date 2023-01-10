//
//  Event.swift
//  EventsCalendar
//
//  Created by Денис on 05.01.2023.
//

import Foundation
import RealmSwift

class EventsManager {
    func eventsForDate(date: Date, in eventsList: Results<EventModel>) -> [EventModel] {
        var daysEvents = [EventModel]()
        for event in eventsList {
            if (Calendar.current.isDate(event.eventDate!, inSameDayAs: date)) {
                daysEvents.append(event)
            }
        }
        return daysEvents
    }
    
}
