//
//  WallpaperSetupViewController.swift
//  EventsCalendar
//
//  Created by Денис on 10.01.2023.
//

import UIKit
import PhotosUI

class WallpaperSetupViewController: UIViewController {
    
    private var itemProviders = [NSItemProvider]()
    
    @IBOutlet weak var wallpaperSwitch: UISwitch!
    @IBOutlet weak var applyButton: UIBarButtonItem!
    @IBOutlet weak var wallpaperImage: UIImageView! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = userDefaults.colorFor(key: "color11")
        applyButton.isEnabled = false
        wallpaperImage.clipsToBounds = true
        wallpaperImage.backgroundColor = .white
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        wallpaperImage.isUserInteractionEnabled = true
        wallpaperImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    private func setupUI() {
        let loadedResult = userDefaults.bool(forKey: "wallpaperSwitch")
        wallpaperSwitch.isOn = loadedResult
        
        guard let data = userDefaults.data(forKey: "wallpaperImage") else { return }
        let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
        let image = UIImage(data: decoded)
        if image != nil {
            wallpaperImage.image = image
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        presentPicker(filter: PHPickerFilter.images)
    }
    
    func presentPicker(filter: PHPickerFilter) {
        var config = PHPickerConfiguration()
        config.filter = filter
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func saveImage() {
        guard wallpaperImage.image != nil else { return }
        guard let data = wallpaperImage.image!.jpegData(compressionQuality: 1.0) else { return }
        let encoded = try! PropertyListEncoder().encode(data)
        userDefaults.set(encoded, forKey: "wallpaperImage")
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        saveImage()
        ThemeManager.shared.themeIsChanged = true
        userDefaults.set(true, forKey: "wallpaperSwitch")
        navigationController?.popViewController(animated: true)
        feedbackGenerator.impactOccurred(intensity: 1.0)
    }
    
    @IBAction func wallpaperShowSwitchAction(_ sender: Any) {
        userDefaults.set(wallpaperSwitch.isOn, forKey: "wallpaperSwitch")
        ThemeManager.shared.themeIsChanged = true
    }
}

// MARK: - PHPickerViewControllerDelegate
extension WallpaperSetupViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        self.itemProviders = results.map (\.itemProvider)
        let item = itemProviders.first
        if ((item?.canLoadObject(ofClass: UIImage.self)) != nil) {
            item?.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self.wallpaperImage.image = image
                        self.applyButton.isEnabled = true
                    } else {
                        print(String(describing: error?.localizedDescription))
                    }
                }
            })
        } else {
            print("Can't load image")
        }
    }
}
