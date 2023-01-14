//
//  EventEditViewController.swift
//  EventsCalendar
//
//  Created by Денис on 05.01.2023.
//

import UIKit
import RealmSwift
import UserNotifications
import Network

let monitor = NWPathMonitor()
let notificationCenter = UNUserNotificationCenter.current()

class EventEditViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var currentEvent: EventModel!
    var currentDate: Date!
    private var colorCircles = [Circle]()
    private var priorityID = 0
    private var selectorIndexPath: IndexPath?
    private var notificationIsEnabled = false
    private var permissionGrantedForNotifications = false
    
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
        checkNotificationPermission()
        setupScreen()
        checkConnection()
    }
    
    private func checkConnection() {
        monitor.pathUpdateHandler = { [self] path in
            if path.status == .satisfied {
                self.addRecordButton.isEnabled = true
            } else {
                self.addRecordButton.isEnabled = false
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    private func checkNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (permissionGranted, error) in
            if permissionGranted {
                self.permissionGrantedForNotifications = true
            } else {
                self.permissionGrantedForNotifications = false
                print(error.debugDescription)
            }
        }
    }
    
    @IBAction func notificationSwitchAction(_ sender: Any) {
        datePicker.isHidden.toggle()
        notificationIsEnabled.toggle()
        if !permissionGrantedForNotifications {
            showAlertForSettings(title: "Напоминания", message: "Для того что бы получать напоминания, активируйте функцию уведомлений в настройках.", settingsText: "Настройки", cancelText: "Отмена")
        }
    }
    
    private func setupScreen() {
        if currentEvent != nil {
            nameTF.text = currentEvent.name
            eventText.text = currentEvent.eventText
            priorityID = currentEvent.priorityID!
            
            if currentEvent.eventWithNotification {
                datePicker.date = currentEvent.eventNotificationDate
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
        } else {
            datePicker.date = currentDate
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
        let newEvent = EventModel(name: nameTF.text!, eventText: eventText.text!, isCompleted: false, eventDate: currentDate, priorityID: priorityID, eventNotificationDate: datePicker.date, eventNotificationID: uniqueRequestID, eventWithNotification: notificationIsEnabled)
        newEvent.name = nameTF.text
        newEvent.eventText = eventText.text
        newEvent.eventDate = currentDate
        
        // Create new notification
        if notificationIsEnabled && currentEvent == nil {
            newEvent.eventNotificationDate = datePicker.date
            createNotification(with: uniqueRequestID, alertText: "Было установлено на")
            newEvent.eventWithNotification = true
        } else {
            newEvent.eventWithNotification = false
        }
        
        // Update current event
        if currentEvent != nil {
            try! realm.write {
                currentEvent.name = newEvent.name
                currentEvent.eventText = newEvent.eventText
                currentEvent.priorityID = priorityID
                
                // Update current notification if it exists
                if notificationIsEnabled {
                    if currentEvent.eventWithNotification && datePicker.date != currentEvent.eventNotificationDate {
                        currentEvent.eventNotificationDate = datePicker.date
                        createNotification(with: currentEvent.eventNotificationID, alertText: "Было изменено на")
                        // Update existed (event without notification)
                    } else if !currentEvent.eventWithNotification {
                        currentEvent.eventWithNotification = true
                        currentEvent.eventNotificationDate = datePicker.date
                        createNotification(with: currentEvent.eventNotificationID, alertText: "Было установлено на")
                        // Just update record (without update current notification)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    currentEvent.eventWithNotification = false
                    removeLastNotification(from: currentEvent.eventNotificationID)
                }
                CloudManager.updateCloudData(event: currentEvent)
            }
        } else {
            CloudManager.saveDataToCloud(event: newEvent) { recordId in
                DispatchQueue.main.async {
                    try! realm.write {
                        newEvent.recordID = recordId
                    }
                }
            }
            StorageManager.saveObject(newEvent)
        }
        feedbackGenerator.impactOccurred(intensity: 1.0)
    }
    
    func createNotification(with uniqueID: String, alertText: String) {
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
                    
                    notificationCenter.add(request) { error in
                        if error != nil {
                            print("Error " + error.debugDescription)
                            return
                        }
                    }
                    self.showAlertForNotification(title: "Напоминание", message: "\(alertText) \(time.getDateStringForNotification(from: date))", okText: "OK") {
                        self.navigationController?.popViewController(animated: true)
                    }
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
    
    private func removeLastNotification(from id: String) {
        guard currentEvent != nil && currentEvent.eventWithNotification else { return }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        print("Уведомление было удалено")
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
        feedbackGenerator.impactOccurred(intensity: 0.5)
        priorityColorsCollectionView.reloadData()
    }
}
