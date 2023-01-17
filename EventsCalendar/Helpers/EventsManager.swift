//
//  Event.swift
//  EventsCalendar
//
//  Created by Денис on 05.01.2023.
//

import Foundation
import CoreData

class EventsManager {
    func eventsForDate(date: Date, in eventsList: [Event]) -> [Event] {
        var daysEvents = [Event]()
        for event in eventsList {
            if (Calendar.current.isDate(event.eventDate!, inSameDayAs: date)) {
                daysEvents.append(event)
            }
        }
        return daysEvents
    }
    
}
