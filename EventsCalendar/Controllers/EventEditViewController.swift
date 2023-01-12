//
//  EventEditViewController.swift
//  EventsCalendar
//
//  Created by Денис on 05.01.2023.
//

import UIKit
import RealmSwift
import UserNotifications


class EventEditViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    let notificationCenter = UNUserNotificationCenter.current()
    private let feedbackGeneratorForSaveAction = UIImpactFeedbackGenerator(style: .heavy)
    private let feedbackGeneratorForColorChanger = UIImpactFeedbackGenerator(style: .rigid)
        
    var colorCircles = [Circle]()
    var currentEvent: EventModel!
    var currentDate: Date!
    private var priorityID = 0
    private var selectorIndexPath: IndexPath?
    private var notificationIsEnabled = false
        
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
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
        nameTF.clearButtonMode = .whileEditing
        priorityColorsCollectionView.dataSource = self
        priorityColorsCollectionView.delegate = self
        datePicker.isHidden = true
        datePicker.minimumDate = Date()
        datePicker.date = currentDate
        setupScreen()

        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (permissionGranted, error) in
            if !permissionGranted {
                print("Permission Denied")
            }
        }
    }
    
    @IBAction func notificationSwitchAction(_ sender: Any) {
        datePicker.isHidden.toggle()
        notificationIsEnabled.toggle()
    }

    private func setupScreen() {
        if currentEvent != nil {
            nameTF.text = currentEvent.name
            eventText.text = currentEvent.eventText
            priorityID = currentEvent.priorityID!
            
            if currentEvent.eventWithNotification && currentEvent.eventNotificationDate != nil {
                datePicker.date = currentEvent.eventNotificationDate!
                notificationSwitch.isOn = currentEvent.eventWithNotification
                notificationIsEnabled = currentEvent.eventWithNotification
                datePicker.isHidden = false
            } else {
                datePicker.isHidden = true
            }
            
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
        let uniqueRequestID = UUID().uuidString
        if notificationIsEnabled {
            createNotification(with: uniqueRequestID)
        } else {
            removeLastNotification()
        }
        
        let newEvent = EventModel(name: nameTF.text!, eventText: eventText.text!, isCompleted: false, eventDate: currentDate, priorityID: priorityID, eventNotificationDate: datePicker.date, eventNotificationID: uniqueRequestID, eventWithNotification: notificationIsEnabled)
        newEvent.name = nameTF.text
        newEvent.eventText = eventText.text
        newEvent.eventDate = currentDate
        if notificationIsEnabled {
            newEvent.eventNotificationDate = datePicker.date
        }
        if currentEvent != nil {
            try! realm.write {
                currentEvent.name = newEvent.name
                currentEvent.eventText = newEvent.eventText
                currentEvent.priorityID = priorityID
                if notificationIsEnabled {
                    currentEvent.eventNotificationDate = datePicker.date
                } else {
                    currentEvent.eventWithNotification = false
                }
            }
        } else {
            StorageManager.saveObject(newEvent)
        }
        feedbackGeneratorForSaveAction.impactOccurred()
    }
    
    func createNotification(with uniqueID: String) {
        notificationCenter.getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                let dv = ""
                let title = self.nameTF.text
                let message = self.eventText.text
                let date = self.datePicker.date
                
                if settings.authorizationStatus == .authorized {
                    let content = UNMutableNotificationContent()
                    content.title = title ?? dv
                    content.body = message ?? dv
                    content.sound = UNNotificationSound.default
                    content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: uniqueID, content: content, trigger: trigger)

                    self.notificationCenter.add(request) { error in
                        if error != nil {
                            print("Error " + error.debugDescription)
                            return
                        }
                    }
                    let ac = UIAlertController(title: "Напоминание установлено", message: "На " + Time().getDateStringForNotification(from: date), preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "ОК", style: .default, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(ac, animated: true)
                } else {
                    let ac = UIAlertController(title: "Разрешить уведомления?", message: "Активируйте эту функцию в настройках", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: "Настройки", style: .default) { _ in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        if UIApplication.shared.canOpenURL(settingsURL) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                    ac.addAction(goToSettings)
                    ac.addAction(UIAlertAction(title: "Отмена", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        save()
        if !notificationIsEnabled {
            navigationController?.popViewController(animated: true)
        }
    }
        
    private func removeLastNotification() {
        guard (currentEvent != nil) && (currentEvent.eventNotificationDate != nil) else { return }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [currentEvent.eventNotificationID])
        print("Уведомление \(currentEvent.eventNotificationDate!) было удалено")
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
