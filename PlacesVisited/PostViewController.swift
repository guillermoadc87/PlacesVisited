//
//  CustomTabBarController2.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/6/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController {
    
    let user = Auth.auth().currentUser
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
    var place: Place?
    
    lazy var postTextView: UITextView = {
        let tv = UITextView()
        tv.delegate = self
        tv.returnKeyType = .done
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.becomeFirstResponder()
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(handlePost))
        
        setupLayout()
    }
    
    func setupLayout() {
        view.addSubview(postTextView)
        
        postTextView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        postTextView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        postTextView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        postTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func handlePost() {
        disableInterection(true)
        
        let imagePath = "posted_photos/" + (user?.uid)! + "/\((place?.name)!).jpg"
        let metadata = StorageMetadata()
        storage.child(imagePath).putData(place?.photoData as! Data, metadata: metadata, completion: { metadata, error in
            if error != nil {
                print(error ?? "")
                self.disableInterection(false)
                return
            }
            
            if let photoURL = metadata?.downloadURL()?.absoluteString {
                let values = ["email": self.user?.email!, "photoURL": photoURL, "date": "\(Date().timeIntervalSince1970)", "text": self.postTextView.text!]
                self.database.child("posts").child((self.user?.uid)!).child((self.place?.name)!).updateChildValues(values, withCompletionBlock: { error, database in
                    if error != nil {
                        print(error ?? "")
                        self.disableInterection(false)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                })
            }
        })
    }
    
    func disableInterection(_ bool: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = !bool
        navigationItem.leftBarButtonItem?.isEnabled = !bool
        postTextView.isEditable = !bool
    }
    
    func handleMiddleButtonClick() {
        print(123)
    }
    
    func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension PostViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
}
