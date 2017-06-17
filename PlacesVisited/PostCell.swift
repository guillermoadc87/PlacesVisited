//
//  PostCell.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/17/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView


class PostCell: BaseCell {
    
    let database = Database.database().reference()
    var user: User?
    var controller: UIViewController?
    
    var post: Post? {
        didSet {
            userEmail.text = post?.email
            postText.text = post?.text
            
            if let user = self.user {
                fetchProfilePicture(user)
            }
            
            if let photoURLString = post?.photoURL {
                //                showActivityIndicator()
                //                print("staring download")
                fetchPhotoWith(urlString: photoURLString)
            }
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "default_profile_picture")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let userEmail: UILabel = {
        let label = UILabel()
        //        label.backgroundColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let postText: UILabel = {
        let label = UILabel()
        //        label.backgroundColor = .purple
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let placeImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let activitiIndicatorView: NVActivityIndicatorView =  {
        let aiv = NVActivityIndicatorView(frame: CGRect(x: 50, y: 50, width: 30, height: 30), type: NVActivityIndicatorType.ballPulse, color: UIColor(red: 59/255, green: 131/255, blue: 247/255, alpha: 1))
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    override func setupLayout() {
        addSubview(profileImageView)
        addSubview(userEmail)
        addSubview(postText)
        addSubview(placeImageView)
        addSubview(activitiIndicatorView)
        
        profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        userEmail.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        userEmail.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        userEmail.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        userEmail.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        postText.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 15).isActive = true
        postText.leftAnchor.constraint(equalTo: profileImageView.leftAnchor).isActive = true
        //        postText.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        //        postText.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[v0]-10-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": postText]))
        postText.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        placeImageView.topAnchor.constraint(equalTo: postText.bottomAnchor, constant: 15).isActive = true
        placeImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        placeImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        //        placeImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
//        activitiIndicatorView.centerXAnchor.constraint(equalTo: placeImageView.centerXAnchor).isActive = true
//        activitiIndicatorView.centerYAnchor.constraint(equalTo: placeImageView.centerYAnchor).isActive = true
        addConstraint(NSLayoutConstraint(item: activitiIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: activitiIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        activitiIndicatorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        activitiIndicatorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = placeImageView.frame.size.width * 9 / 16
        placeImageView.frame.size.height = height
        //        placeImageView.heightAnchor.constraint(equalToConstant: height)
    }
    
    func fetchProfilePicture(_ user: User) {
//        self.activitiIndicatorView.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        database.child("profile_picture/\(user.uid)/profilePictureURL").observe(.value, with: { snapshot in
            let profilePictureURL = snapshot.value as! String
            self.profileImageView.downloadImageWithURL(urlString: profilePictureURL, completionHandler: { profilePictureData, error in
                if error != nil {
                    print(error ?? "")
                    return
                }
                
                if let photo = UIImage(data: profilePictureData!) {
                    performUIUpdatesOnMain {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.profileImageView.image = photo
//                        self.activitiIndicatorView.stopAnimating()
                    }
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.activitiIndicatorView.stopAnimating()
                }
                
                
            })
        })
        
    }
    
    func fetchPhotoWith(urlString: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.activitiIndicatorView.startAnimating()
        self.placeImageView.downloadImageWithURL(urlString: urlString, completionHandler: { photoData, error in
            if error != nil {
                print(error ?? "")
                self.controller?.displayAlert(title: "Connection Problem", message: "Please look for the nearest WIFI")
            }
            if let photo = UIImage(data: photoData!) {
                performUIUpdatesOnMain {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.placeImageView.image = photo
                    self.activitiIndicatorView.stopAnimating()
                }
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activitiIndicatorView.stopAnimating()
            }
        })
    }
    
}
