//
//  ProfileViewController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/7/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class ProfileViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
    var loggedUser: User?
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 59/255, green: 131/255, blue: 247/255, alpha: 1)
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
    
    let activitiIndicatorView: NVActivityIndicatorView =  {
        let aiv = NVActivityIndicatorView(frame: CGRect(x: 50, y: 50, width: 30, height: 30), type: NVActivityIndicatorType.ballPulse, color: UIColor(red: 59/255, green: 131/255, blue: 247/255, alpha: 1))
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
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
        view.addSubview(activitiIndicatorView)
        
        profileImageView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 50).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        logoutButton.bottomAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.widthAnchor.constraint(equalTo: profileImageView.widthAnchor).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        usernameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 5).isActive = true
        usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        activitiIndicatorView.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        activitiIndicatorView.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        activitiIndicatorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        activitiIndicatorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    func fetchProfilePicture(_ user: User) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.activitiIndicatorView.startAnimating()
        database.child("profile_picture/\(user.uid)/profilePictureURL").observe(.value, with: { snapshot in
            
            if let profilePictureURL = snapshot.value as? String {
                self.profileImageView.downloadImageWithURL(urlString: profilePictureURL, completionHandler: { profilePictureData, error in
                    if error != nil {
                        print(error ?? "")
                        return
                    }
                    if let photo = UIImage(data: profilePictureData!) {
                        performUIUpdatesOnMain {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            self.activitiIndicatorView.stopAnimating()
                            self.profileImageView.image = photo
                        }
                    } else {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.activitiIndicatorView.stopAnimating()
                    }
                })

            }else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activitiIndicatorView.stopAnimating()
            }
            
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activitiIndicatorView.startAnimating()
        let photoData = UIImagePNGRepresentation(photo)! as Data
        let metadata = StorageMetadata()
        self.storage.child("profile_picture/\(self.loggedUser?.uid)").putData(photoData, metadata: metadata, completion: { metadata, error in
            if error != nil {
                print(error ?? "")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                self.hideActivityIndicator()
                return
            }
                
            if let profilePictureURL = metadata?.downloadURL()?.absoluteString {
                let values = ["profilePictureURL": profilePictureURL]
                self.database.child("profile_picture/\((self.loggedUser?.uid)!)").updateChildValues(values, withCompletionBlock: { error, database in
                    if error != nil {
                        print(error ?? "")
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.activitiIndicatorView.stopAnimating()
                        return
                    }
                    self.profileImageView.image = photo
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.activitiIndicatorView.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                })
            }
        })
        
    }
}
