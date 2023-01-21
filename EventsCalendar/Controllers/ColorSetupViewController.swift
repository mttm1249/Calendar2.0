//
//  ColorSetupViewController.swift
//  EventsCalendar
//
//  Created by Денис on 08.01.2023.
//

import UIKit
import Pikko


protocol ColorUpdate: AnyObject {
    func reloadColors()
}

class ColorSetupViewController: UIViewController, PikkoDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var recentColor = UIColor()
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var recentColorsCollectionView: UICollectionView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var currentOption: SettingsOption!
    weak var delegate: ColorUpdate?
    var bottomViewIsOpen = false
    
    func writeBackColor(color: UIColor) {
        ThemeManager.shared.themeIsChanged = true
        recentColor = color
        userDefaults.setColor(color: color, forKey: currentOption.key)
        delegate?.reloadColors()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomViewIsOpen = true
        recentColorsCollectionView.delegate = self
        recentColorsCollectionView.dataSource = self
        view.backgroundColor = userDefaults.colorFor(key: "color11")
        navigationItem.title = currentOption.name
        setupBottomView()
        setupPikko()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ThemeManager.shared.recentColors.append(recentColor)
    }
        
    func setupPikko() {
        let pikko = Pikko(dimension: 300, setToColor: currentOption.colorOption)
        pikko.delegate = self
        self.view.addSubview(pikko)
        pikko.translatesAutoresizingMaskIntoConstraints = false
        pikko.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        pikko.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100).isActive = true
    }
    
    func setupBottomView() {
        guard ThemeManager.shared.recentColors.count > 0 else { return }
        heightConstraint.constant = bottomViewIsOpen ? 180 : 0
        UIView.animate(
            withDuration: 1 / 3, delay: 0, options: .curveEaseIn,
            animations: { self.view.layoutIfNeeded() })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ThemeManager.shared.recentColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recentColorItem", for: indexPath)
        cell.backgroundColor = ThemeManager.shared.recentColors[indexPath.item]
        cell.layer.cornerRadius = 20
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.systemGray2.cgColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = ThemeManager.shared.recentColors[indexPath.item]
        userDefaults.setColor(color: color, forKey: currentOption.key)
        delegate?.reloadColors()
        navigationController?.popViewController(animated: true)
        feedbackGenerator.impactOccurred(intensity: 2.0)
    }
    
}

