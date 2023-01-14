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

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ColorUpdate {
    
    private var options = [SettingsOption]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var optionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        scrollView.delegate = self
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
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
    
    private func prepareColorTheme() {
        let color1  = userDefaults.colorFor(key: "color1")
        let color2  = userDefaults.colorFor(key: "color2")
        let color3  = userDefaults.colorFor(key: "color3")
        let color4  = userDefaults.colorFor(key: "color4")
        let color5  = userDefaults.colorFor(key: "color5")
        let color6  = userDefaults.colorFor(key: "color6")
        let color7  = userDefaults.colorFor(key: "color7")
        let color8  = userDefaults.colorFor(key: "color8")
        let color9  = userDefaults.colorFor(key: "color9")
        let color10 = userDefaults.colorFor(key: "color10")
        let color11 = userDefaults.colorFor(key: "color11")
        let color12 = userDefaults.colorFor(key: "color12")
        let color13 = userDefaults.colorFor(key: "color13")
        
        let colorTheme = [SettingsOption(name: "Название месяца", colorOption: color1, key: "color1"),
                          SettingsOption(name: "Названия дней недели", colorOption: color2, key: "color2"),
                          SettingsOption(name: "Дни выбранного месяца", colorOption: color3, key: "color3"),
                          SettingsOption(name: "Дни следующего месяца", colorOption: color4, key: "color4"),
                          SettingsOption(name: "Цвет индикатора", colorOption: color5, key: "color5"),
                          SettingsOption(name: "Цвет индикатора (выбран)", colorOption: color13, key: "color13"),
                          SettingsOption(name: "Сегодняшний день", colorOption: color6, key: "color6"),
                          SettingsOption(name: "Выбранный день", colorOption: color7, key: "color7"),
                          SettingsOption(name: "Выбран сегодняшний день", colorOption: color8, key: "color8"),
                          SettingsOption(name: "Выходные дни", colorOption: color9, key:  "color9"),
                          SettingsOption(name: "Цвет выбранной даты", colorOption: color10, key: "color10"),
                          SettingsOption(name: "Кнопка добавления записи", colorOption: color12, key: "color12"),
                          SettingsOption(name: "Цвет фона", colorOption: color11, key: "color11"),
                          SettingsOption(name: "Обои", colorOption: .clear, id: 1)
        ]
        for color in colorTheme {
            options.append(color)
        }
    }
    
    // Passing data by segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "colorSetup" {
            guard let indexPath = optionsTableView.indexPathForSelectedRow else { return }
            let colorVC = segue.destination as! ColorSetup
            let option = options[indexPath.row]
            colorVC.currentOption = option
            colorVC.delegate = self
        }
    }
    
    //MARK: TableView DataSource
    
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
    
    @IBAction func resetButtonAction(_ sender: Any) {
        showAlert(title: "Внимание!", message: "Все настройки будут сброшены", okActionText: "ОК", cancelText: "Отмена") {
            userDefaults.set(false, forKey: "wallpaperSwitch")
            ThemeManager.shared.themeIsChanged = true
            self.performSegue(withIdentifier: "unwindSegue", sender: self)
        }
    }
}

// MARK: UIScrollViewDelegate
extension SettingsViewController: UIScrollViewDelegate {
    // Disable horizontal scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}
