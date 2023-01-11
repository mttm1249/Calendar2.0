//
//  ViewController - Extensions.swift
//  EventsCalendar
//
//  Created by Денис on 09.01.2023.
//

import UIKit

extension ViewController {
    func setDefaultTheme() {
        userDefaults.set(true, forKey: "defaultThemeActive")
        userDefaults.setColor(color: ThemeManager.shared.color1, forKey: "color1")
        userDefaults.setColor(color: ThemeManager.shared.color2, forKey: "color2")
        userDefaults.setColor(color: ThemeManager.shared.color3, forKey: "color3")
        userDefaults.setColor(color: ThemeManager.shared.color4, forKey: "color4")
        userDefaults.setColor(color: ThemeManager.shared.color5, forKey: "color5")
        userDefaults.setColor(color: ThemeManager.shared.color6, forKey: "color6")
        userDefaults.setColor(color: ThemeManager.shared.color7, forKey: "color7")
        userDefaults.setColor(color: ThemeManager.shared.color8, forKey: "color8")
        userDefaults.setColor(color: ThemeManager.shared.color9, forKey: "color9")
        userDefaults.setColor(color: ThemeManager.shared.color10, forKey: "color10")
        userDefaults.setColor(color: ThemeManager.shared.color11, forKey: "color11")
        userDefaults.setColor(color: ThemeManager.shared.color12, forKey: "color12")
        userDefaults.setColor(color: ThemeManager.shared.color13, forKey: "color13")
    }
    
    func setupCalendarAppearance() {
        let color1  = userDefaults.colorFor(key: "color1")
        let color2  = userDefaults.colorFor(key: "color2")
        let color3  = userDefaults.colorFor(key: "color3")
        let color4  = userDefaults.colorFor(key: "color4")
        let color5  = userDefaults.colorFor(key: "color5")
        let color6  = userDefaults.colorFor(key: "color6")
        let color7  = userDefaults.colorFor(key: "color7")
        let color8  = userDefaults.colorFor(key: "color8")
        let color9  = userDefaults.colorFor(key: "color9")
        let color10 = userDefaults.colorFor(key: "color10")
        let color12 = userDefaults.colorFor(key: "color12")
        let сolor13 = userDefaults.colorFor(key: "color13")
        
        calendar.appearance.caseOptions           = [.headerUsesUpperCase]
        calendar.appearance.weekdayFont           = .boldSystemFont(ofSize: 16)
        calendar.appearance.titleFont             = .boldSystemFont(ofSize: 15)
        calendar.appearance.headerTitleColor      = color1
        calendar.appearance.weekdayTextColor      = color2
        calendar.appearance.titleDefaultColor     = color3
        calendar.appearance.titlePlaceholderColor = color4
        calendar.appearance.eventDefaultColor     = color5
        calendar.appearance.todayColor            = color6
        calendar.appearance.selectionColor        = color7
        calendar.appearance.todaySelectionColor   = color8
        calendar.appearance.titleWeekendColor     = color9
        calendar.appearance.titleSelectionColor   = color10
        calendar.appearance.eventSelectionColor   = сolor13

        roundAddButton.backgroundColor = color12
        view.backgroundColor = userDefaults.colorFor(key: "color11")
    }
}
