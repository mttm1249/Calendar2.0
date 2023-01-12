//
//  TintTextField.swift
//  MyEventPlanner
//
//  Created by Денис on 12.01.2023.
//

import UIKit

class TintTextField: UITextField {
    
    var tintedClearImage: UIImage?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setupTintColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupTintColor()
    }
    
    func setupTintColor() {
        self.borderStyle = .roundedRect
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderColor = self.tintColor.cgColor
        self.layer.borderWidth = 1
        self.backgroundColor = .white
        self.textColor = .black
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tintClearImage()
    }
    
    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let image = button.image(for: .highlighted) {
                    if self.tintedClearImage == nil {
                        tintedClearImage = self.tintImage(image: image, color: self.tintColor)
                    }
                    button.setImage(self.tintedClearImage, for: .normal)
                    button.setImage(self.tintedClearImage, for: .highlighted)
                }
            }
        }
    }
    
    private func tintImage(image: UIImage, color: UIColor) -> UIImage {
        let size = image.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: .zero, blendMode: CGBlendMode.normal, alpha: 1.0)
        
        context?.setFillColor(color.cgColor)
        context?.setBlendMode(CGBlendMode.sourceIn)
        context?.setAlpha(1.0)
        
        let rect = CGRect(x: CGPoint.zero.x, y: CGPoint.zero.y, width: image.size.width, height: image.size.height)
        UIGraphicsGetCurrentContext()?.fill(rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage ?? UIImage()
    }
}
