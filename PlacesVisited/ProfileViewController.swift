//
//  ProfileViewController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/7/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
    var loggedUser: User?
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.image = UIImage(named: "default_profile_picture")
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImage)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.activityIndicatorViewStyle = .gray
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    func showActivityIndicator(){
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Profile"
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            if user != loggedUser {
                fetchProfilePicture(user)
                usernameLabel.text = user.email
                loggedUser = user
            }
        }
    }
    
    func setupLayout() {
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(logoutButton)
        view.addSubview(activityIndicator)
        
        
        
        profileImageView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 50).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        logoutButton.bottomAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 100)
        logoutButton.heightAnchor.constraint(equalToConstant: 10)
        
        usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5).isActive = true
        usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
    }
    
    func fetchProfilePicture(_ user: User) {
        showActivityIndicator()
        database.child("profile_picture/\(user.uid)/profilePictureURL").observe(.value, with: { snapshot in
            let profilePictureURL = snapshot.value as! String
            self.profileImageView.downloadImageWithURL(urlString: profilePictureURL, completionHandler: { profilePictureData, error in
                if error != nil {
                    print(error ?? "")
                    return
                }
                performUIUpdatesOnMain {
                    self.profileImageView.image = UIImage(data: profilePictureData!)
                    self.hideActivityIndicator()
                }
                
            })
        })
        
    }
    
    func handleProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func handleLogout() {
        appDelegate.handleLogout(sender: self)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            saveImage(image)
        }
    }
    
    func saveImage(_ photo: UIImage) {
        showActivityIndicator()
        let photoData = UIImagePNGRepresentation(photo)! as Data
        let metadata = StorageMetadata()
        DispatchQueue.global(qos: .userInitiated).async {
            self.storage.child("profile_picture/\(self.loggedUser?.uid)").putData(photoData, metadata: metadata, completion: { metadata, error in
                if error != nil {
                    print(error ?? "")
                    self.hideActivityIndicator()
                    return
                }
                
                if let profilePictureURL = metadata?.downloadURL()?.absoluteString {
                    let values = ["profilePictureURL": profilePictureURL]
                    self.database.child("profile_picture/\((self.loggedUser?.uid)!)").updateChildValues(values, withCompletionBlock: { error, database in
                        if error != nil {
                            print(error ?? "")
                            self.hideActivityIndicator()
                            return
                        }
                        self.profileImageView.image = photo
                        self.hideActivityIndicator()
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            })
        }
        
    }
}
