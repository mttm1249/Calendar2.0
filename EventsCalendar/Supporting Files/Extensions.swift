//
//  Extensions.swift
//  EventsCalendar
//
//  Created by Денис on 07.01.2023.
//

import UIKit
import Network

// MARK: - Global
let time = Time()
let feedbackGenerator = UIImpactFeedbackGenerator()
let userDefaults = UserDefaults.standard
let monitor = NWPathMonitor()
let notificationCenter = UNUserNotificationCenter.current()

// MARK: - Hide Keyboard Method

extension UIViewController {
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
