//
//  LocalizableText.swift
//  EventList
//
//  Created by Денис on 18.01.2023.
//

import Foundation

class LocalizableText {
    class Settings {
        // Color options
        static let optionName1  = NSLocalizedString("SettingsViewController.optionName1", comment: "")
        static let optionName2  = NSLocalizedString("SettingsViewController.optionName2", comment: "")
        static let optionName3  = NSLocalizedString("SettingsViewController.optionName3", comment: "")
        static let optionName4  = NSLocalizedString("SettingsViewController.optionName4", comment: "")
        static let optionName5  = NSLocalizedString("SettingsViewController.optionName5", comment: "")
        static let optionName6  = NSLocalizedString("SettingsViewController.optionName6", comment: "")
        static let optionName7  = NSLocalizedString("SettingsViewController.optionName7", comment: "")
        static let optionName8  = NSLocalizedString("SettingsViewController.optionName8", comment: "")
        static let optionName9  = NSLocalizedString("SettingsViewController.optionName9", comment: "")
        static let optionName10 = NSLocalizedString("SettingsViewController.optionName10", comment: "")
        static let optionName11 = NSLocalizedString("SettingsViewController.optionName11", comment: "")
        static let optionName12 = NSLocalizedString("SettingsViewController.optionName12", comment: "")
        static let optionName13 = NSLocalizedString("SettingsViewController.optionName13", comment: "")
        static let optionName14 = NSLocalizedString("SettingsViewController.optionName14", comment: "")
        
        // Set to defaults - button Alert
        static let titleText = NSLocalizedString("SettingsViewController.titleText", comment: "")
        static let messageText = NSLocalizedString("SettingsViewController.messageText", comment: "")
        static let cancelText = NSLocalizedString("SettingsViewController.cancelText", comment: "")
    }
    
    class MainPage {
        // Done events counter
        static let doneText = NSLocalizedString("MainViewController.doneText", comment: "")

        // Record deleting Alert
        static let titleText = NSLocalizedString("MainViewController.titleText", comment: "")
        static let messageText = NSLocalizedString("MainViewController.messageText", comment: "")
        static let cancelText = NSLocalizedString("MainViewController.cancelText", comment: "")
    }
    
    class EventEditPage {
        // Turn on notification Alert
        static let titleText = NSLocalizedString("EventEditViewController.titleText", comment: "")
        static let messageText = NSLocalizedString("EventEditViewController.messageText", comment: "")
        static let settingsText = NSLocalizedString("EventEditViewController.settingsText", comment: "")
        static let cancelText = NSLocalizedString("EventEditViewController.cancelText", comment: "")
        
        // Creating notification alert
        static let notificationTitleText = NSLocalizedString("EventEditViewController.notificationTitleText", comment: "")
        static let createdNewText = NSLocalizedString("EventEditViewController.createdNewText", comment: "")
        static let changedExistedText = NSLocalizedString("EventEditViewController.changedExistedText", comment: "")
    }
}
