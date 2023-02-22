//
//  SettingsViewController+Extensions.swift
//  EventList
//
//  Created by mttm on 22.02.2023.
//

import UIKit

extension SettingsViewController {
    func prepareColorTheme() {
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
        let color11 = userDefaults.colorFor(key: "color11")
        let color12 = userDefaults.colorFor(key: "color12")
        let color13 = userDefaults.colorFor(key: "color13")
        
        let colorTheme = [SettingsOption(name: LocalizableText.Settings.optionName1, colorOption: color1, key: "color1"),
                          SettingsOption(name: LocalizableText.Settings.optionName2, colorOption: color2, key: "color2"),
                          SettingsOption(name: LocalizableText.Settings.optionName3, colorOption: color3, key: "color3"),
                          SettingsOption(name: LocalizableText.Settings.optionName4, colorOption: color9, key:  "color9"),
                          SettingsOption(name: LocalizableText.Settings.optionName5, colorOption: color4, key: "color4"),
                          SettingsOption(name: LocalizableText.Settings.optionName6, colorOption: color5, key: "color5"),
                          SettingsOption(name: LocalizableText.Settings.optionName7, colorOption: color13, key: "color13"),
                          SettingsOption(name: LocalizableText.Settings.optionName8, colorOption: color6, key: "color6"),
                          SettingsOption(name: LocalizableText.Settings.optionName9, colorOption: color7, key: "color7"),
                          SettingsOption(name: LocalizableText.Settings.optionName10, colorOption: color8, key: "color8"),
                          SettingsOption(name: LocalizableText.Settings.optionName11, colorOption: color10, key: "color10"),
                          SettingsOption(name: LocalizableText.Settings.optionName12, colorOption: color12, key: "color12"),
                          SettingsOption(name: LocalizableText.Settings.optionName13, colorOption: color11, key: "color11"),
                          SettingsOption(name: LocalizableText.Settings.optionName14, colorOption: .clear, id: 1)
        ]
        for color in colorTheme {
            options.append(color)
        }
    }
}
