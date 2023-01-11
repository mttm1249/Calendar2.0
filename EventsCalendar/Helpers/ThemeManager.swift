//
//  ThemesManager.swift
//  EventsCalendar
//
//  Created by Денис on 08.01.2023.
//

import UIKit

let userDefaults = UserDefaults.standard

class ThemeManager {
    var themeIsChanged = false
    
    let color1  = #colorLiteral(red: 0.2549019608, green: 0.2745098039, blue: 0.3019607843, alpha: 1)
    let color2  = #colorLiteral(red: 0.4406057274, green: 0.4770534495, blue: 0.5300029363, alpha: 1)
    let color3  = #colorLiteral(red: 0.2549019608, green: 0.2745098039, blue: 0.3019607843, alpha: 1)
    let color4  = #colorLiteral(red: 0.4406057274, green: 0.4770534495, blue: 0.5300029363, alpha: 1)
    let color5  = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
    let color6  = #colorLiteral(red: 0.7139339004, green: 0.3407340069, blue: 0.9686274529, alpha: 1)
    let color7  = #colorLiteral(red: 0.4406057274, green: 0.4770534495, blue: 0.5300029363, alpha: 1)
    let color8  = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    let color9  = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    let color10 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    let color11 = #colorLiteral(red: 0.4860396981, green: 0.5505498052, blue: 0.666649878, alpha: 1)
    let color12 = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
    let color13 = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
    static let shared = ThemeManager()
    private init() {}
}

// MARK: - UserDefaults

extension UserDefaults {
  func colorFor(key: String) -> UIColor? {
    var colorReturnded: UIColor?
    if let colorData = data(forKey: key) {
      do {
        if let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
          colorReturnded = color
        }
      } catch {
        print("Error UserDefaults")
      }
    }
    return colorReturnded
  }
  
  func setColor(color: UIColor?, forKey key: String) {
    var colorData: NSData?
    if let color = color {
      do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData?
        colorData = data
      } catch {
        print("Error UserDefaults")
      }
    }
    set(colorData, forKey: key)
  }
}
