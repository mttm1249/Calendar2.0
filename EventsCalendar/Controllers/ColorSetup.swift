//
//  ColorSetup.swift
//  EventsCalendar
//
//  Created by Денис on 08.01.2023.
//

import UIKit
import Pikko


protocol ColorUpdate: AnyObject {
    func reloadColors()
}

class ColorSetup: UIViewController, PikkoDelegate {
    
    var currentOption: SettingsOption!
    weak var delegate: ColorUpdate?

    func writeBackColor(color: UIColor) {
        ColorPalette.shared.themeIsChanged = true
        userDefaults.setColor(color: color, forKey: currentOption.key)
        delegate?.reloadColors()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = userDefaults.colorFor(key: "color11")
        navigationItem.title = currentOption.name
        setupPikko()
    }
    
    func setupPikko() {
        let pikko = Pikko(dimension: 300, setToColor: currentOption.colorOption)
        pikko.delegate = self
        self.view.addSubview(pikko)
        pikko.translatesAutoresizingMaskIntoConstraints = false
        pikko.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pikko.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100).isActive = true
    }
    
}
