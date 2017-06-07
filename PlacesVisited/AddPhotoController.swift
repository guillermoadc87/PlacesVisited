//
//  AddPhotoController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/4/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit

class AddPhotoController: UIViewController {
    
    lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
//        button.setTitle("Camera", for: .normal)
//        button.setTitleColor(UIColor.white, for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setImage(UIImage(named: "camera"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleGetPhoto(sender:)), for: .touchUpInside)
        button.tag = 0
        return button
    }()
    
    lazy var libraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Library", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleGetPhoto(sender:)), for: .touchUpInside)
        button.tag = 1
        return button
    }()
    
//    let anotherButton: SpecialButton = {
//        let sbutton = SpecialButton(image: UIImage(named: "camera")!, title: "Camera")
//        sbutton.translatesAutoresizingMaskIntoConstraints = false
//        sbutton.backgroundColor = UIColor(white: 0.85, alpha: 1)
//        return sbutton
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        setupLayout()
    }
    
    func setupLayout() {
        view.addSubview(cameraButton)
        view.addSubview(libraryButton)
        
        cameraButton.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        cameraButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        cameraButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: view.frame.size.height/2).isActive = true
        
        libraryButton.topAnchor.constraint(equalTo: cameraButton.bottomAnchor).isActive = true
        libraryButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        libraryButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        libraryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func handleGetPhoto(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if sender.tag == 0 {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension AddPhotoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            print("The image is: ", image)
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
