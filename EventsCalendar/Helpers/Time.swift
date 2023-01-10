//
//  Time.swift
//  EventsCalendar
//
//  Created by Денис on 06.01.2023.
//

import Foundation

class Time {
        
    func getDateString(from: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMMM, yyyy"
        let dateString = dateFormatter.string(from: from)
        return dateString
    }
}
