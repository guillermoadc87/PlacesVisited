//
//  ViewController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/3/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ViewController: UITableViewController {
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handlePresentAddPhotoVC))
        
        configureAuth()
        
//        if let uid = Auth.auth().currentUser?.uid {
//            Database.database()
//        } else {
//            handleLogout()
//        }
        
    }
    
    func configureAuth() {
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            
            if let activeUser = user {
                if self.user != activeUser {
                    self.user = activeUser
                    print(self.user ?? "")
                }
            } else {
                self.handleLogout()
            }
        }
    }
    
    func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let loginError {
            print(loginError)
        }
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    func handlePresentAddPhotoVC() {
        let nc = UINavigationController(rootViewController: AddPhotoController())
        present(nc, animated: true)
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
}
