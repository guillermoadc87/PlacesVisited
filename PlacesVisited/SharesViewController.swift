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
        cell.controller = self
        cell.user = loggedUser
        cell.post = post
        
        return cell
    }
    
}



