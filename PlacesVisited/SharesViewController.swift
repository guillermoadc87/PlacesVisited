//
//  SharesViewController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/6/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class SharesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let database = Database.database().reference()
    var postArray:[Post]? = []
    var loggedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
            if user != loggedUser {
                loggedUser = user
            }
        }
        
        self.collectionView!.register(PostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.backgroundColor = UIColor(white: 0.8, alpha: 1)
        
        navigationItem.title = "Shares"
        
        fetchPost()
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchPost()
//    }
    
    func fetchPost() {
        print("fetchPost")
        
        database.child("posts").observe(.childAdded, with: { snapshot in
            if let dictionaty = snapshot.value as? [String: AnyObject] {
                for (placeName, post) in dictionaty {
                    var dic = (post as! [String: AnyObject])
                    dic["name"] = placeName as AnyObject?
                    let timeInterval = Double(dic["date"] as! String)
                    dic["date"] = Date.init(timeIntervalSince1970: timeInterval!) as AnyObject?
                    let post = Post()
                    post.setValuesForKeys(dic)
                    self.postArray?.append(post)
                    self.postArray = self.postArray?.sorted(by: {$0.date! > $1.date!})
                }
                performUIUpdatesOnMain {
                    self.collectionView?.reloadData()
                }
            }
        })
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let numberOfItems = postArray?.count else { return 0 }
        print("numberOfItemsInSection: ", numberOfItems)
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: view.frame.size.height/2)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PostCell
        
        let post = postArray?[indexPath.item]
//        cell.backgroundColor = .blue
        cell.user = loggedUser
        cell.post = post
        
        return cell
    }
    
}

class PostCell: BaseCell {
    
    let database = Database.database().reference()
    var user: User?
    
    var post: Post? {
        didSet {
            userEmail.text = post?.email
            postText.text = post?.text
            
            if let user = self.user {
                fetchProfilePicture(user)
            }
            
            if let photoURLString = post?.photoURL {
//                showActivityIndicator()
                print("staring download")
                self.placeImageView.downloadImageWithURL(urlString: photoURLString, completionHandler: { photoData, error in
                    if error != nil {
                        print(error)
                    }
                    if let data = photoData {
                        performUIUpdatesOnMain {
                            self.placeImageView.image = UIImage(data: data)
//                            self.hideActivityIndicator()
                        }
                    }
                })
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
    
    override func setupLayout() {
        addSubview(profileImageView)
        addSubview(userEmail)
        addSubview(postText)
        addSubview(placeImageView)
        addSubview(activityIndicator)
        
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
        
        activityIndicator.centerXAnchor.constraint(equalTo: placeImageView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: placeImageView.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = placeImageView.frame.size.width * 9 / 16
        placeImageView.frame.size.height = height
//        placeImageView.heightAnchor.constraint(equalToConstant: height)
    }
    
    func fetchProfilePicture(_ user: User) {
        //        showActivityIndicator()
        database.child("profile_picture/\(user.uid)/profilePictureURL").observe(.value, with: { snapshot in
            let profilePictureURL = snapshot.value as! String
            self.profileImageView.downloadImageWithURL(urlString: profilePictureURL, completionHandler: { profilePictureData, error in
                if error != nil {
                    print(error ?? "")
                    return
                }
                performUIUpdatesOnMain {
                    self.profileImageView.image = UIImage(data: profilePictureData!)
                    //                    self.hideActivityIndicator()
                }
                
            })
        })
        
    }
    
}




