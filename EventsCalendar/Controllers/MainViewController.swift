//
//  ViewController.swift
//  EventsCalendar
//
//  Created by Денис on 05.01.2023.
//

import UIKit
import FSCalendar
import UserNotifications
import CoreData

class MainViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
        
    var fetchedResultsController: NSFetchedResultsController<Event>?

    private var defaultColors = [SettingsOption]()
    private var eventsArray: [Event] = []
    private var selectedDate = Date()
    let roundAddButton = UIButton()
    
    @IBOutlet weak var wallpaperImage: UIImageView!
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        registerCell()
        setupAddButton()
        setupCalendar()
        setupTheme()
        setFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ThemeManager.shared.themeIsChanged {
            ThemeManager.shared.themeIsChanged = false
            setupTheme()
        }
        fetchData()
        tableView.reloadData()
    }
        
    func setFetchedResultsController() {
        let fetch = NSFetchRequest<Event>(entityName: "Event")
        fetch.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreDataManager.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
    }
    
    func fetchData() {
        do {
            try fetchedResultsController?.performFetch()
            if fetchedResultsController?.fetchedObjects != nil {
                eventsArray = (fetchedResultsController?.fetchedObjects)!
            }
        } catch {
            print("Error fetching products")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if fetchedResultsController?.fetchedObjects != nil {
            eventsArray = (fetchedResultsController?.fetchedObjects)!
            calendar.reloadData()
        }
    }
    
    func loadWallpaperImage() {
        guard let data = userDefaults.data(forKey: "wallpaperImage") else { return }
        let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
        let image = UIImage(data: decoded)
        if image != nil && userDefaults.bool(forKey: "wallpaperSwitch") {
            wallpaperImage.image = image
        } else if image == nil || !userDefaults.bool(forKey: "wallpaperSwitch") {
            wallpaperImage.image = UIImage()
        }
    }
    
    // Register custom TableView cell
    private func registerCell() {
        let cell = UINib(nibName: "EventCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "eventCell")
    }
    
    func setupTheme() {
        if !userDefaults.bool(forKey: "defaultThemeActive") {
            setDefaultTheme()
            setupCalendarAppearance()
            loadWallpaperImage()
        } else {
            setupCalendarAppearance()
            loadWallpaperImage()
        }
    }
    
    private func setupCalendar() {
        if calendar.today != nil {
            selectedDate = calendar.today!
        }
        calendar.firstWeekday = UInt(2)
    }
    
    private func setupAddButton() {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let buttonSize = CGFloat(60)
        
        roundAddButton.frame = CGRect(x: screenWidth - (buttonSize + 35), y: screenHeight - (buttonSize * 2), width: buttonSize, height: buttonSize)
        roundAddButton.layer.cornerRadius = buttonSize / 2
        roundAddButton.setImage(UIImage(named: "plusImg"), for: .normal)
        roundAddButton.tintColor = .white
        roundAddButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        roundAddButton.layer.cornerRadius = roundAddButton.frame.size.height / 2
        roundAddButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        roundAddButton.layer.opacity = 0.8
        
        view.addSubview(roundAddButton)
    }
    
    @objc func addButtonAction(sender: UIButton!) {
        performSegue(withIdentifier: "addRecord", sender: self)
        feedbackGenerator.impactOccurred(intensity: 0.5)
    }
    
    // Counting events in every day of month for indicators
    func countRecords(date: Date) -> Int {
        let filtered = eventsArray.filter{ $0.eventDate == date }.count
        return filtered
    }
    
    // Passing data by segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addRecord" {
            let editVC = segue.destination as! EventEditViewController
            editVC.currentDate = selectedDate
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let event = EventsManager().eventsForDate(date: selectedDate, in: eventsArray)[indexPath.row]
            editVC.currentEvent = event
        }
    }
    
    // MARK: Calendar Setup
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        tableView.reloadData()
        feedbackGenerator.impactOccurred(intensity: 0.5)
    }
    
    // Shows events indication on dates
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var dates: [String] = []
        for event in eventsArray {
            dates.append(time.getDateString(from: event.eventDate!))
        }
        if dates.contains(time.getDateString(from: date)) {
            return countRecords(date: date)
        }
        return 0
    }
    
    // MARK: TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventsManager().eventsForDate(date: selectedDate, in: eventsArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell {
            let event = EventsManager().eventsForDate(date: selectedDate, in: eventsArray)[indexPath.row]
            cell.setup(model: event)
            return cell
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "addRecord", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showAlert(title: LocalizableText.MainPage.titleText, message: LocalizableText.MainPage.messageText, okActionText: "OK", cancelText: LocalizableText.MainPage.cancelText) {
                let event = EventsManager().eventsForDate(date: self.selectedDate, in: self.eventsArray)[indexPath.row]
                let eventID = event.eventNotificationID!.uuidString
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [eventID])
                
                CoreDataManager.managedContext.delete(event)
                CoreDataManager.shared.saveContext()
                tableView.deleteRows(at: [indexPath], with: .left)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "") { [self] (action, view, completion) in
            let indexesToRedraw = [indexPath]
            let event = EventsManager().eventsForDate(date: selectedDate, in: eventsArray)[indexPath.row]
            
            if !event.isCompleted {
                event.isCompleted = true
            } else {
                event.isCompleted = false
            }

            CoreDataManager.shared.saveContext()
            tableView.reloadRows(at: indexesToRedraw, with: .fade)
            tableView.reloadData()
        }
        editAction.backgroundColor = .systemGreen
        let config = UISwipeActionsConfiguration(actions: [editAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
    @IBAction func unwindSegueToMainScreen(segue: UIStoryboardSegue) {
        guard segue.identifier == "unwindSegue" else { return }
        userDefaults.set(false, forKey: "defaultThemeActive")
        setupTheme()
        feedbackGenerator.impactOccurred(intensity: 1.0)
    }
    
}
