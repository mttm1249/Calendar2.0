//
//  EventViewController.swift
//  EventsCalendar
//
//  Created by Денис on 05.01.2023.
//

import UIKit

class EventViewController: UIViewController, EventProtocol {
    func addEvent(date: Date) {
        
    }
    

    var currentEvent: EventModel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var eventText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = userDefaults.colorFor(key: "color11")
        eventText.layer.borderWidth = 0.2
        eventText.layer.borderColor = UIColor.systemGray2.cgColor
        eventText.backgroundColor = .white
        nameLabel.backgroundColor = .white
        nameLabel.clipsToBounds = true
        nameLabel.layer.borderWidth = 0.2
        nameLabel.layer.borderColor = UIColor.systemGray2.cgColor
        dateLabel.text = Time().getDateString(from: currentEvent.eventDate!)
        nameLabel.text = currentEvent.name
        eventText.text = currentEvent.eventText
    }
        
    @IBAction func editButtonAction(_ sender: Any) {
        guard let editVC = storyboard?.instantiateViewController(withIdentifier: "editRecord") as? EventEditViewController else { return }
        editVC.currentEvent = currentEvent
        editVC.currentDate = currentEvent.eventDate
        //          editVC.isEdited = true
        editVC.delegate = self
        editVC.modalPresentationStyle = .pageSheet
        present(editVC, animated: true)
    }
}
