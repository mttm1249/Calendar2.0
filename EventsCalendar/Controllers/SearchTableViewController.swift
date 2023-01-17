//
//  SearchTableViewController.swift
//  EventsCalendar
//
//  Created by Денис on 07.01.2023.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
   
    @IBOutlet weak var tableView: UITableView!

    var fetchedResultsController: NSFetchedResultsController<Event>?
    let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    var showAllActive = false

    private var allEvents: [Event] = []
    private var foundedEvents: [Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        view.backgroundColor = userDefaults.colorFor(key: "color11")
        tableView.delegate = self
        tableView.dataSource = self
        showSearchBar()
        setFetchedResultsController()
        fetchData()
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
                allEvents = (fetchedResultsController?.fetchedObjects)!
            }
        } catch {
            print("Error fetching products")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    // MARK: Search controller
    func showSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Искать в заметках"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    @IBAction func showAllAction(_ sender: Any) {
        searchController.searchBar.text = ""
        showAllActive.toggle()
        tableView.reloadWithAnimation()
        feedbackGenerator.impactOccurred(intensity: 0.5)
    }

    // MARK: - Table view data source

    // Register custom TableView cell
    private func registerCell() {
        let cell = UINib(nibName: "EventCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "eventCell")
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return foundedEvents.count
        }
         if showAllActive {
             return allEvents.count
         }
        return 0
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as? EventTableViewCell {
            if isFiltering {
                let event = foundedEvents[indexPath.row]
                cell.setup(model: event)
                return cell
            } else if !isFiltering && showAllActive {
                allEvents.sort(by: { $0.priorityID < $1.priorityID })
                let event = allEvents[indexPath.row]
                cell.setup(model: event)
                return cell
            }
        }
        return UITableViewCell()

    }
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!.lowercased())
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        foundedEvents = allEvents.filter { ($0.name?.lowercased().contains(searchText))! }
        if foundedEvents.count == 0 {
            foundedEvents = allEvents.filter { ($0.eventText?.lowercased().contains(searchText))! }
        }
        tableView.reloadData()
    }
}

// MARK: - UITableView - Animation
extension UITableView {
    func reloadWithAnimation() {
        self.reloadData()
        let tableViewHeight = self.bounds.size.height
        let cells = self.visibleCells
        var delayCounter = 0
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: -tableViewHeight)
        }
        for cell in cells {
            UIView.animate(withDuration: 0.4, delay: 0.03 * Double(delayCounter),usingSpringWithDamping: 5.0, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}
