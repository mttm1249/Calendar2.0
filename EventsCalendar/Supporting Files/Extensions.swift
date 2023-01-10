//
//  Extensions.swift
//  EventsCalendar
//
//  Created by Денис on 07.01.2023.
//

import UIKit

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
