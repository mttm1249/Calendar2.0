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

        // Configure the view for the selected state
    }

}
