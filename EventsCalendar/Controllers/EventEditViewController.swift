//
//  EventEditViewController.swift
//  EventsCalendar
//
//  Created by Денис on 05.01.2023.
//

import UIKit
import RealmSwift

protocol EventProtocol: AnyObject {
    func addEvent(date: Date)
}

class EventEditViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private let feedbackGeneratorForSaveAction = UIImpactFeedbackGenerator(style: .heavy)
    private let feedbackGeneratorForColorChanger = UIImpactFeedbackGenerator(style: .rigid)
    
    var colorCircles = [Circle]()

    var currentEvent: EventModel!
    var currentDate: Date!
    weak var delegate: EventProtocol?
    private var priorityID = 0
    private var selectorIndexPath: IndexPath?
        
    @IBOutlet weak var addRecordButton: UIBarButtonItem!
    @IBOutlet weak var eventTextOutlet: UITextView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var eventText: UITextView!
    
    @IBOutlet weak var priorityColorsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        prepareColors()
        view.backgroundColor = userDefaults.colorFor(key: "color11")
        navigationItem.title = Time().getDateString(from: currentDate)
        eventTextOutlet.layer.borderWidth = 0.2
        eventTextOutlet.layer.borderColor = UIColor.systemGray2.cgColor
        eventTextOutlet.backgroundColor = .white
        nameTF.backgroundColor = .white
        setupScreen()
        priorityColorsCollectionView.dataSource = self
        priorityColorsCollectionView.delegate = self
    }
    
    private func setupScreen() {
        if currentEvent != nil {
            nameTF.text = currentEvent.name
            eventText.text = currentEvent.eventText
            priorityID = currentEvent.priorityID!
            switch priorityID {
            case 1:
                selectorIndexPath = [0, 0]
            case 2:
                selectorIndexPath = [0, 1]
            case 3:
                selectorIndexPath = [0, 2]
            case 4:
                selectorIndexPath = [0, 3]
            case 5:
                selectorIndexPath = [0, 4]
            case 6:
                selectorIndexPath = [0, 5]
            case 7:
                selectorIndexPath = [0, 6]
            default:
                break
            }
        }
        priorityColorsCollectionView.reloadData()
    }
    
    
    private func prepareColors() {
        let colors = [Circle(circleColor: .color1, colorID: 1),
                      Circle(circleColor: .color2, colorID: 2),
                      Circle(circleColor: .color3, colorID: 3),
                      Circle(circleColor: .color4, colorID: 4),
                      Circle(circleColor: .color5, colorID: 5),
                      Circle(circleColor: .color6, colorID: 6),
                      Circle(circleColor: .color7, colorID: 7)
        ]
        
        for color in colors {
            colorCircles.append(color)
        }
    }
    // Saving object to REALM
    private func save() {
        let newEvent = EventModel(name: nameTF.text!, eventText: eventText.text!, isCompleted: false, eventDate: currentDate, priorityID: priorityID)
        if currentEvent != nil {
            try! realm.write {
                currentEvent.name = newEvent.name
                currentEvent.eventText = newEvent.eventText
                currentEvent.priorityID = priorityID
            }
        } else {
            StorageManager.saveObject(newEvent)
        }
        feedbackGeneratorForSaveAction.impactOccurred()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let newEvent = EventModel()
        newEvent.name = nameTF.text
        newEvent.eventText = eventText.text
        newEvent.eventDate = currentDate
        save()
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: CollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorCircles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCollectionViewCell
        let color = colorCircles[indexPath.row].circleColor
        cell.backgroundColor = color
        cell.layer.cornerRadius = 20
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.systemGray2.cgColor
        if selectorIndexPath == indexPath {
            cell.cellImage.image = UIImage(systemName: "checkmark")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        } else {
            cell.cellImage.image = UIImage()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let colorCircle = colorCircles[indexPath.item]
        if selectorIndexPath == indexPath {
            priorityID = 0
            selectorIndexPath = nil
        } else {
            priorityID = colorCircle.colorID
            selectorIndexPath = indexPath
        }
        feedbackGeneratorForColorChanger.impactOccurred()
        priorityColorsCollectionView.reloadData()
    }
    
}
