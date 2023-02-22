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

class MainViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<Event>?
    
    private var eventToShow: Event!
    private var defaultColors = [SettingsOption]()
    private var eventsArray: [Event] = []
    private var completedEventsArray: [Event] = []
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
        
        let contentInset = UIEdgeInsets(top: -50, left: 0, bottom: 0, right: 0)
        tableView.contentInset = contentInset
        tableView.setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: false)
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
        fetch.sortDescriptors = [NSSortDescriptor(key: "createDate", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: CoreDataManager.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
    }
    
    func fetchData() {
        do {
            try fetchedResultsController?.performFetch()
            if fetchedResultsController?.fetchedObjects != nil {
                let fetchedArray = (fetchedResultsController?.fetchedObjects)!
                eventsArray = fetchedArray.filter { !$0.isCompleted }
                completedEventsArray = fetchedArray.filter { $0.isCompleted }
            }
        } catch {
            print("Error fetching")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if fetchedResultsController?.fetchedObjects != nil {
            let fetchedArray = (fetchedResultsController?.fetchedObjects)!
            eventsArray = fetchedArray.filter { !$0.isCompleted }
            completedEventsArray = fetchedArray.filter { $0.isCompleted }
            
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
        
        roundAddButton.frame = CGRect(x: screenWidth - (buttonSize + 35), y: screenHeight - (buttonSize * 2) , width: buttonSize, height: buttonSize)
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
            eventToShow = getEvent(from: indexPath)
            editVC.currentEvent = eventToShow
        }
        
        if segue.identifier == "search" {
            let searchVC = segue.destination as! SearchViewController
            searchVC.delegate = self
        }
    }
    
    @IBAction func unwindSegueToMainScreen(segue: UIStoryboardSegue) {
        guard segue.identifier == "unwindSegue" else { return }
        userDefaults.set(false, forKey: "defaultThemeActive")
        setupTheme()
        feedbackGenerator.impactOccurred(intensity: 1.0)
    }
    
}

// MARK: - FSCalendarDataSource
extension MainViewController: UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate {
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
        
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventTableViewCell
        let event = getEvent(from: indexPath)
        cell.eventDateLabel.isHidden = true
        cell.setup(model: event)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "addRecord", sender: self)
        feedbackGenerator.impactOccurred(intensity: 0.5)
    }
    
    // Delete action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
            self.showAlert(title: LocalizableText.MainPage.titleText, message: LocalizableText.MainPage.messageText, okActionText: "OK", cancelText: LocalizableText.MainPage.cancelText) { [self] in
                let event = getEvent(from: indexPath)
                let eventID = event.eventNotificationID!.uuidString
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [eventID])
                CoreDataManager.managedContext.delete(event)
                CoreDataManager.shared.saveContext()
                tableView.deleteRows(at: [indexPath], with: .left)
                delay {
                    self.tableView.reloadData()
                }
            }
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // Delay for cell deleting animation (.left)
    func delay(closure: @escaping() -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            closure()
        }
    }
    
    // The method checks the event, in which section it is located
    func getEvent(from index: IndexPath) -> Event {
        var event: Event!
        if index.section == 0 {
            event = EventsManager().eventsForDate(date: selectedDate, in: eventsArray)[index.row]
        } else {
            event = EventsManager().eventsForDate(date: selectedDate, in: completedEventsArray)[index.row]
        }
        return event
    }
    
    // Left slide action
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: "") { [self] (action, view, completion) in
            let event = getEvent(from: indexPath)
            
            if !event.isCompleted {
                event.isCompleted = true
            } else {
                event.isCompleted = false
            }
            
            feedbackGenerator.impactOccurred(intensity: 1.0)
            CoreDataManager.shared.saveContext()
            tableView.reloadData()
        }
        doneAction.image = UIImage(systemName: "checkmark")
        doneAction.backgroundColor = .systemGreen
        let config = UISwipeActionsConfiguration(actions: [doneAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        if EventsManager().eventsForDate(date: selectedDate, in: completedEventsArray).count == 0 {
            headerView.textLabel?.textColor = .clear
        } else {
            headerView.textLabel?.textColor = .darkGray
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return EventsManager().eventsForDate(date: selectedDate, in: eventsArray).count
        } else {
            return EventsManager().eventsForDate(date: selectedDate, in: completedEventsArray).count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            return "\(LocalizableText.MainPage.doneText) \(EventsManager().eventsForDate(date: selectedDate, in: completedEventsArray).count)"
        }
    }
}

// Delegate method for edit event from searchVC
extension MainViewController: PresentEditVC {
    func getRecord(event: Event) {
        eventToShow = event
    }
    
    func goToAddEventVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyboard.instantiateViewController(withIdentifier: "editRecord") as! EventEditViewController
        editVC.currentEvent = eventToShow
        editVC.currentDate = eventToShow.eventDate
        navigationController?.pushViewController(editVC, animated: true)
    }
}
