//
//  ViewController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/2/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginController: UIViewController {
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(self.handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = SpacedTextField()
        tf.placeholder = "Email"
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .white
        return tf
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = SpacedTextField()
        tf.placeholder = "Password"
        tf.delegate = self
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .white
        return tf
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(self.handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    lazy var fbLogin: FBSDKLoginButton = {
        let fbl = FBSDKLoginButton()
        fbl.translatesAutoresizingMaskIntoConstraints = false
        fbl.delegate = self
        fbl.readPermissions = ["public_profile", "email", "user_friends"]
        return fbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        setupLayout()
    }
    
    func setupLayout() {
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginRegisterButton)
        view.addSubview(fbLogin)
        
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -10).isActive = true
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v0]-20-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": loginRegisterSegmentedControl]))
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true

        emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: emailTextField.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        loginRegisterButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[v0]-20-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": loginRegisterButton]))
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        fbLogin.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //        fbLogin.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 20).isActive = true
        fbLogin.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        fbLogin.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        //        fbLogin.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    
    
    // Change login button text
    func handleLoginRegisterChange() {
        let indexSeleted = loginRegisterSegmentedControl.selectedSegmentIndex
        let title = loginRegisterSegmentedControl.titleForSegment(at: indexSeleted)
        loginRegisterButton.setTitle(title, for: .normal)
    }
    
    func handleLoginRegister() {
        guard let email = emailTextField.text else {
            self.displayAlert(title: "", message: "An Email most be specify")
            return
        }
        guard let password = passwordTextField.text else {
            self.displayAlert(title: "", message: "A Password most be specify")
            return
        }
        
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            Auth.auth().signIn(withEmail: email, password: password, completion: { user, error in
                if error != nil {
                    print(error ?? "")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            Auth.auth().createUser(withEmail: email, password: password, completion: { user, error in
                if error != nil {
                    print(error ?? "")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func dismissKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
}

extension LoginController: FBSDKLoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential, completion: { user, error in
            if error != nil {
                print(error ?? "")
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"]).start { (connection, result, error) in
            if error != nil {
                print(error ?? "")
                return
            }
            print("Succesfully logged in with FB")
        }
        
    }
}

extension LoginController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

