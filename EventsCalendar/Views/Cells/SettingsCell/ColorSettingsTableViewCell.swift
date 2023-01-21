//
//  ColorSettingsTableViewCell.swift
//  EventsCalendar
//
//  Created by Денис on 08.01.2023.
//

import UIKit

class ColorSettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var accesoryImage: UIImageView!
    @IBOutlet weak var optionText: UILabel!
    @IBOutlet weak var optionColor: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            let bgColorView = UIView()
            bgColorView.backgroundColor = #colorLiteral(red: 0.9004991651, green: 0.9118354917, blue: 0.9116360545, alpha: 1)
            self.selectedBackgroundView = bgColorView
        }

}
