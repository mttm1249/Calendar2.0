//
//  SettingsViewController.swift
//  EventsCalendar
//
//  Created by Денис on 08.01.2023.
//

import UIKit

struct SettingsOption {
    var name: String!
    var colorOption: UIColor!
    var key: String!
    var id: Int!
}

class SettingsViewController: UIViewController, ColorUpdate {
    
    var options = [SettingsOption]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var optionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        scrollView.delegate = self
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.backgroundColor = .white
        prepareColorTheme()
        view.backgroundColor = userDefaults.colorFor(key: "color11")
    }
    
    //delegate method
    func reloadColors() {
        options.removeAll()
        prepareColorTheme()
        optionsTableView.reloadData()
        view.backgroundColor = userDefaults.colorFor(key: "color11")
    }
    
    // Register custom TableView cell
    private func registerCell() {
        let cell = UINib(nibName: "ColorSettingsCell", bundle: nil)
        optionsTableView.register(cell, forCellReuseIdentifier: "colorOption")
    }
        
    // Passing data by segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "colorSetup" {
            guard let indexPath = optionsTableView.indexPathForSelectedRow else { return }
            let colorVC = segue.destination as! ColorSetupViewController
            let option = options[indexPath.row]
            colorVC.currentOption = option
            colorVC.delegate = self
        }
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        showAlert(title: LocalizableText.Settings.titleText, message: LocalizableText.Settings.messageText, okActionText: "OK", cancelText: LocalizableText.Settings.cancelText) {
            userDefaults.set(false, forKey: "wallpaperSwitch")
            ThemeManager.shared.themeIsChanged = true
            self.performSegue(withIdentifier: "unwindSegue", sender: self)
        }
    }
}

// MARK: - TableView DataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "colorOption", for: indexPath) as! ColorSettingsTableViewCell
        cell.optionText.text = options[indexPath.row].name
        let color = options[indexPath.row].colorOption
        cell.optionColor.backgroundColor = color
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if options[indexPath.row].id != nil {
            performSegue(withIdentifier: "wallpaperSetup", sender: self)
        } else {
            performSegue(withIdentifier: "colorSetup", sender: self)
        }
        feedbackGenerator.impactOccurred(intensity: 0.5)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension SettingsViewController: UIScrollViewDelegate {
    // MARK: UIScrollViewDelegate
    // Disable horizontal scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}
