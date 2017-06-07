//
//  CustomTabBarController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/5/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker

class CustomTabBarController: UITabBarController {
    
    let buttonWidth: CGFloat = 56
    var buttonsShown: Bool = false
    
    lazy var middleButton: UIButton = {
        let mb = UIButton(type: .custom)
        mb.setBackgroundImage(UIImage(named: "add"), for: .normal)
        mb.setBackgroundImage(UIImage(named: "add"), for: UIControlState.focused)
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.addTarget(self, action: #selector(handleMiddleButtonClicked), for: .touchUpInside)
        return mb
    }()
    
    var cameraButtonXConstrain: NSLayoutConstraint?
    var cameraButtonYConstrain: NSLayoutConstraint?
    
    lazy var cameraButton: UIButton = {
        let cb = UIButton(type: .system)
        cb.tag = 0
        cb.setBackgroundImage(UIImage(named: "camera"), for: UIControlState.normal)
        cb.setBackgroundImage(UIImage(named: "camera"), for: UIControlState.focused)
        cb.translatesAutoresizingMaskIntoConstraints = false
        cb.addTarget(self, action: #selector(handleImagePicker(sender:)), for: .touchUpInside)
        return cb
    }()
    
    var libraryButtonXConstrain: NSLayoutConstraint?
    var libraryButtonYConstrain: NSLayoutConstraint?
    
    lazy var libraryButton: UIButton = {
        let lb = UIButton(type: .custom)
        lb.tag = 1
        lb.setImage(UIImage(named: "library"), for: UIControlState.normal)
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.addTarget(self, action: #selector(handleImagePicker(sender:)), for: .touchUpInside)
        return lb
    }()
    
    let blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc1 = ViewController()
        vc1.tabBarItem = UITabBarItem(title: "Places", image: UIImage(named: "map"), selectedImage: UIImage(named: "map"))
        let nav1 = UINavigationController(rootViewController: vc1)
        
        let vc2 = SharesViewController()
        vc2.tabBarItem = UITabBarItem(title: "Shares", image: UIImage(named: "share"), selectedImage: UIImage(named: "map"))
        let nav2 = UINavigationController(rootViewController: vc2)
        
        let vc3 = UIViewController()
        vc3.tabBarItem = UITabBarItem(title: "", image: nil, selectedImage: UIImage(named: "map"))
        let nav3 = UINavigationController(rootViewController: vc3)
        
        let vc4 = AddPhotoController()
        vc4.tabBarItem = UITabBarItem(title: "Add", image: UIImage(named: "map"), selectedImage: UIImage(named: "map"))
        let nav4 = UINavigationController(rootViewController: vc4)
        
        let vc5 = UIViewController()
        vc5.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), selectedImage: UIImage(named: "map"))
        let nav5 = UINavigationController(rootViewController: vc5)
        
        viewControllers = [nav1, nav2, nav3, nav4, nav5]
        
        setupButton()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let config = GMSPlacePickerConfig(viewport: nil)
//        let placePicker = GMSPlacePickerViewController(config: config)
//        present(placePicker, animated: true, completion: nil)
//    }
    
    
    func setupButton() {
        //view.addSubview(cameraButton)
        //view.addSubview(libraryButton)
        view.insertSubview(cameraButton, belowSubview: tabBar)
        view.insertSubview(libraryButton, belowSubview: tabBar)
        view.addSubview(middleButton)
        
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        middleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        middleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2).isActive = true
        middleButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        middleButton.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        cameraButtonXConstrain = cameraButton.centerXAnchor.constraint(equalTo: middleButton.centerXAnchor)
        cameraButtonXConstrain?.isActive = true
        cameraButtonYConstrain = cameraButton.centerYAnchor.constraint(equalTo: middleButton.centerYAnchor)
        cameraButtonYConstrain?.isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: buttonWidth/2).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: buttonWidth/2).isActive = true

        libraryButtonXConstrain = libraryButton.centerXAnchor.constraint(equalTo: middleButton.centerXAnchor)
        libraryButtonXConstrain?.isActive = true
        libraryButtonYConstrain = libraryButton.centerYAnchor.constraint(equalTo: middleButton.centerYAnchor)
        libraryButtonYConstrain?.isActive = true
        libraryButton.widthAnchor.constraint(equalToConstant: buttonWidth/2).isActive = true
        libraryButton.heightAnchor.constraint(equalToConstant: buttonWidth/2).isActive = true
        
        //blackView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor)
        //blackView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        //blackView.leftAnchor.constraint(equalTo: view.leftAnchor)
        //blackView.rightAnchor.constraint(equalTo: view.rightAnchor)
        
    }
    
    func handleDismissButtons() {
        print("Aqui estoy: ", buttonsShown)
        if buttonsShown {
            print("Hide Buttons")
            handleMiddleButtonClicked()
        }
    }
    
    func handleMiddleButtonClicked() {
        if !buttonsShown {
            cameraButtonXConstrain?.constant = -(middleButton.frame.size.width + 5)
            cameraButtonYConstrain?.constant = -(middleButton.frame.size.height + 5)
            
            libraryButtonXConstrain?.constant = middleButton.frame.size.width + 5
            libraryButtonYConstrain?.constant = -(middleButton.frame.size.height + 5)
            
            self.view.insertSubview(self.blackView, belowSubview: self.cameraButton)
            blackView.alpha = 0
            blackView.frame = view.frame
            blackView.frame.size.height = blackView.frame.size.height - tabBar.frame.size.height
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissButtons)))
        } else {
            cameraButtonXConstrain?.constant = 0
            cameraButtonYConstrain?.constant = 0
            
            libraryButtonXConstrain?.constant = 0
            libraryButtonYConstrain?.constant = 0
        }
        
        UIView.animate(withDuration: 1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            if !self.buttonsShown {
                self.blackView.alpha = 1
                self.middleButton.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                self.middleButton.setBackgroundImage(UIImage(named: "minus"), for: .normal)
                self.cameraButton.layer.transform = CATransform3DMakeScale(2, 2, 2)
                self.libraryButton.layer.transform = CATransform3DMakeScale(2, 2, 2)
            } else {
                self.blackView.alpha = 0
                self.middleButton.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
                self.middleButton.setBackgroundImage(UIImage(named: "add"), for: .normal)
                self.cameraButton.layer.transform = CATransform3DIdentity
                self.libraryButton.layer.transform = CATransform3DIdentity
            }
            }
            , completion: nil)
        
        buttonsShown = !buttonsShown
    }
    
    func handleImagePicker(sender: UIButton) {
        handleDismissButtons()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if sender.tag == 0 {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        }
        
        present(imagePicker, animated: true, completion: nil)
//        navigationController?.pushViewController(UIViewController(), animated: true)
    }
}

extension CustomTabBarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            print("The image is: ", image)
            let config = GMSPlacePickerConfig(viewport: nil)
            let placePicker = GMSPlacePickerViewController(config: config)
            present(placePicker, animated: true, completion: nil)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
