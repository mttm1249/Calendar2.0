//
//  SearchTableViewController.swift
//  EventsCalendar
//
//  Created by Денис on 07.01.2023.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    var showAllActive = false
    
    private var allEvents: Results<EventModel>!
    private var foundedEvents: Results<EventModel>!


    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        view.backgroundColor = userDefaults.colorFor(key: "color11")
        tableView.delegate = self
        tableView.dataSource = self
        allEvents = realm.objects(EventModel.self)
        showSearchBar()
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
            if isFiltering && foundedEvents != nil {
                let event = foundedEvents.reversed()[indexPath.row]
                cell.setup(model: event)
                return cell
            } else if !isFiltering && showAllActive {
                allEvents = allEvents.sorted(byKeyPath: "priorityID", ascending: true)
                let event = allEvents.reversed()[indexPath.row]
                cell.setup(model: event)
                return cell
            }
        }
        return UITableViewCell()
        
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        foundedEvents = allEvents.filter("name CONTAINS[cd] %@ OR eventText CONTAINS[cd] %@", searchText, searchText)
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
