//
//  Alerts.swift
//  EventsCalendar
//
//  Created by Денис on 10.01.2023.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, okActionText: String, cancelText: String, closure: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionText, style: .destructive) { (_) in
            closure()
        }
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}
