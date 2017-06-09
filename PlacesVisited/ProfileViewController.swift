//
//  ProfileViewController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/7/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.image = UIImage(named: "default_profile_picture")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        print(appDelegate.user?.email)
        usernameLabel.text = appDelegate.user?.email
    }
    
    
    func setupLayout() {
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(logoutButton)
        
        
        
        profileImageView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 50).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        logoutButton.bottomAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 100)
        logoutButton.heightAnchor.constraint(equalToConstant: 10)
        
        usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5)
        usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        
    }
}
