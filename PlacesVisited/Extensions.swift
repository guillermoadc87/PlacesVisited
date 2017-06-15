//
//  Extensions.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/4/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import Foundation
import UIKit

class SpacedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}


class SpecialButton: UIView {
    var imageView = UIImageView()
    var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(image: UIImage, title: String) {
        self.init(frame: CGRect.zero)
        self.imageView.image = image
        self.label.text = title
        setupLayout()
    }
    
    func setupLayout() {
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -(imageView.frame.width/2)).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIViewController {
    
    // Alert
    func displayAlert(title:String, message:String?) {
        
        if let message = message {
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension UIImageView {
    
    func downloadImageWithURL(urlString: String, completionHandler: @escaping (_ data: Data?, _ error: NSError?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completionHandler(nil, error as NSError?)
                return
            }
            
            completionHandler(data, nil)
            }.resume()
        
    }
    
}
