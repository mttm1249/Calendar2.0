//
//  EventTableViewCell.swift
//  EventsCalendar
//
//  Created by Денис on 06.01.2023.
//

import UIKit

class EventTableViewCell: UITableViewCell {
        
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventText: UILabel!
    @IBOutlet weak var completeIndicator: UIView!
    @IBOutlet weak var priorityIndicator: UIView!
    @IBOutlet weak var notificationInfoView: UIStackView!
    @IBOutlet weak var notificationDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let indicatorSize = CGFloat(20)
        priorityIndicator.frame = CGRect(x: 0, y: 0, width: indicatorSize, height: indicatorSize)
        priorityIndicator.layer.cornerRadius = indicatorSize / 2
        priorityIndicator.layer.borderWidth = 1
        priorityIndicator.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setup(model: Event) {
        if model.eventWithNotification && model.eventNotificationDate! > Date() {
            notificationInfoView.isHidden = false
            notificationDateLabel.text = time.getDateStringForNotification(from: model.eventNotificationDate!)
        } else {
            notificationInfoView.isHidden = true
        }
        eventName.text = model.name
        eventText.text = model.eventText
        if model.isCompleted {
            completeIndicator.isHidden = false
            completeIndicator.backgroundColor = .systemGreen
        } else {
            completeIndicator.isHidden = true
            completeIndicator.backgroundColor = .clear
        }
        switch model.priorityID {
        case 1:
            priorityIndicator.backgroundColor = .color1
            priorityIndicator.layer.borderWidth = 0
        case 2:
            priorityIndicator.backgroundColor = .color2
            priorityIndicator.layer.borderWidth = 0
        case 3:
            priorityIndicator.backgroundColor = .color3
            priorityIndicator.layer.borderWidth = 0
        case 4:
            priorityIndicator.backgroundColor = .color4
            priorityIndicator.layer.borderWidth = 0
        case 5:
            priorityIndicator.backgroundColor = .color5
            priorityIndicator.layer.borderWidth = 0
        case 6:
            priorityIndicator.backgroundColor = .color6
            priorityIndicator.layer.borderWidth = 0
        case 7:
            priorityIndicator.backgroundColor = .color7
            priorityIndicator.layer.borderWidth = 0
        case 8:
            priorityIndicator.backgroundColor = .clear
            priorityIndicator.layer.borderWidth = 1
        default:
            break
        }
    }
}

