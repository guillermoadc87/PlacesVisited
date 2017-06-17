//
//  CustomTabBarController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/5/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GooglePlaces
import GoogleMaps
import GooglePlacePicker

class CustomTabBarController: UITabBarController {
    
    let context = AppDelegate.viewContext
    
    var pickedImage: UIImage?
    let buttonWidth: CGFloat = 56
    var buttonsShown: Bool = false
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    lazy var middleButton: UIButton = {
        let mb = UIButton(type: .custom)
        mb.setBackgroundImage(UIImage(named: "add"), for: .normal)
        mb.setBackgroundImage(UIImage(named: "add"), for: UIControlState.focused)
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.addTarget(self, action: #selector(handleMiddleButtonClicked), for: .touchUpInside)
        return mb
    }()
    
    var cameraButtonXConstrain: NSLayoutConstraint?
    var cameraButtonYConstrain: NSLayoutConstraint?
    
    lazy var cameraButton: UIButton = {
        let cb = UIButton(type: .system)
        cb.tag = 0
        cb.setBackgroundImage(UIImage(named: "camera"), for: UIControlState.normal)
        cb.setBackgroundImage(UIImage(named: "camera"), for: UIControlState.focused)
        cb.translatesAutoresizingMaskIntoConstraints = false
        cb.addTarget(self, action: #selector(handleImagePicker(sender:)), for: .touchUpInside)
        return cb
    }()
    
    var libraryButtonXConstrain: NSLayoutConstraint?
    var libraryButtonYConstrain: NSLayoutConstraint?
    
    lazy var libraryButton: UIButton = {
        let lb = UIButton(type: .custom)
        lb.tag = 1
        lb.setImage(UIImage(named: "library"), for: UIControlState.normal)
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.addTarget(self, action: #selector(handleImagePicker(sender:)), for: .touchUpInside)
        return lb
    }()
    
    let blackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    let vc1 = PlacesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc2 = SharesViewController(collectionViewLayout: UICollectionViewFlowLayout())
        vc2.tabBarItem = UITabBarItem(title: "Shares", image: UIImage(named: "share"), selectedImage: UIImage(named: "share"))
        let nav2 = UINavigationController(rootViewController: vc2)
        
        let vc3 = UIViewController()
        vc3.tabBarItem = UITabBarItem(title: "", image: nil, selectedImage: nil)
        let nav3 = UINavigationController(rootViewController: vc3)
        
        let vc4 = FavoritePhotoController(collectionViewLayout: UICollectionViewFlowLayout())
        vc4.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(named: "heart"), selectedImage: UIImage(named: "heart"))
        let nav4 = UINavigationController(rootViewController: vc4)
        
        let vc5 = ProfileViewController()
        vc5.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile"))
        let nav5 = UINavigationController(rootViewController: vc5)
        
        vc1.tabBarItem = UITabBarItem(title: "Places", image: UIImage(named: "map"), selectedImage: UIImage(named: "map"))
        vc1.favoriteController = vc4
        let nav1 = UINavigationController(rootViewController: vc1)
        
        viewControllers = [nav1, nav2, nav3, nav4, nav5]
        
        configureAuth()
        setupButton()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let config = GMSPlacePickerConfig(viewport: nil)
//        let placePicker = GMSPlacePickerViewController(config: config)
//        present(placePicker, animated: true, completion: nil)
//    }
    
    func configureAuth() {
        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let activeUser = user {
                if appDelegate.user != activeUser {
                    appDelegate.user = activeUser
                    print(user ?? "")
                }
            } else {
                appDelegate.handleLogout(sender: self)
            }
        }
    }
    
    func setupButton() {
        //view.addSubview(cameraButton)
        //view.addSubview(libraryButton)
        view.insertSubview(cameraButton, belowSubview: tabBar)
        view.insertSubview(libraryButton, belowSubview: tabBar)
        view.addSubview(middleButton)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        middleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        middleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2).isActive = true
        middleButton.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        middleButton.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        
        cameraButtonXConstrain = cameraButton.centerXAnchor.constraint(equalTo: middleButton.centerXAnchor)
        cameraButtonXConstrain?.isActive = true
        cameraButtonYConstrain = cameraButton.centerYAnchor.constraint(equalTo: middleButton.centerYAnchor)
        cameraButtonYConstrain?.isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: buttonWidth/2).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: buttonWidth/2).isActive = true

        libraryButtonXConstrain = libraryButton.centerXAnchor.constraint(equalTo: middleButton.centerXAnchor)
        libraryButtonXConstrain?.isActive = true
        libraryButtonYConstrain = libraryButton.centerYAnchor.constraint(equalTo: middleButton.centerYAnchor)
        libraryButtonYConstrain?.isActive = true
        libraryButton.widthAnchor.constraint(equalToConstant: buttonWidth/2).isActive = true
        libraryButton.heightAnchor.constraint(equalToConstant: buttonWidth/2).isActive = true
        
    }
    
    func handleDismissButtons() {
        if buttonsShown {
            handleMiddleButtonClicked()
        }
    }
    
    func handleMiddleButtonClicked() {
        if !buttonsShown {
            cameraButtonXConstrain?.constant = -(middleButton.frame.size.width + 5)
            cameraButtonYConstrain?.constant = -(middleButton.frame.size.height + 5)
            
            libraryButtonXConstrain?.constant = middleButton.frame.size.width + 5
            libraryButtonYConstrain?.constant = -(middleButton.frame.size.height + 5)
            
            self.view.insertSubview(self.blackView, belowSubview: self.cameraButton)
            blackView.alpha = 0
            blackView.frame = view.frame
            blackView.frame.size.height = blackView.frame.size.height - tabBar.frame.size.height
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismissButtons)))
        } else {
            cameraButtonXConstrain?.constant = 0
            cameraButtonYConstrain?.constant = 0
            
            libraryButtonXConstrain?.constant = 0
            libraryButtonYConstrain?.constant = 0
        }
        
        UIView.animate(withDuration: 1, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            if !self.buttonsShown {
                self.blackView.alpha = 1
//                self.middleButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.middleButton.setBackgroundImage(UIImage(named: "minus"), for: .normal)
                self.cameraButton.layer.transform = CATransform3DMakeScale(2, 2, 2)
                self.libraryButton.layer.transform = CATransform3DMakeScale(2, 2, 2)
            } else {
                self.blackView.alpha = 0
//                self.middleButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.middleButton.setBackgroundImage(UIImage(named: "add"), for: .normal)
                self.cameraButton.layer.transform = CATransform3DIdentity
                self.libraryButton.layer.transform = CATransform3DIdentity
            }
            }
            , completion: nil)
        
        
        
        buttonsShown = !buttonsShown
    }
    
    func handleImagePicker(sender: UIButton) {
        handleDismissButtons()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if sender.tag == 0 {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        }
        
        present(imagePicker, animated: true, completion: nil)
//        let config = GMSPlacePickerConfig(viewport: nil)
//        let placePicker = GMSPlacePickerViewController(config: config)
//        present(placePicker, animated: true, completion: nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        handleDismissButtons()
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
}

extension CustomTabBarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as! UIImage? {
            pickedImage = image
            let config = GMSPlacePickerConfig(viewport: nil)
            let placePicker = GMSPlacePickerViewController(config: config)
            placePicker.delegate = self
            present(placePicker, animated: true, completion: nil)
        }
        
        
    }
}

extension CustomTabBarController: GMSPlacePickerViewControllerDelegate {
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        print(place.name)
        var country: Country?
        var city: City?
        var placeVisited: Place?
        
        for component in place.addressComponents! {
            if component.type == "country" {
                let request: NSFetchRequest = Country.fetchRequest()
                country = verifyDuplicityForRequest(request as! NSFetchRequest<NSFetchRequestResult>, withParameter: component.name) as? Country
                print(country)
                if country == nil {
                    print(component.name)
                    country = Country(context: context)
                    country?.name = component.name
                }
            } else if component.type == "locality" {
                let request: NSFetchRequest = City.fetchRequest()
                city = verifyDuplicityForRequest(request as! NSFetchRequest<NSFetchRequestResult>, withParameter: component.name) as? City
                print(city)
                if city == nil {
                    print(component.name)
                    city = City(context: context)
                    city?.name = component.name
                }
            }
            
        }
        if let cityCountry = city?.country {
           print(cityCountry)
        } else {
            city?.country = country
        }
        let request: NSFetchRequest = Place.fetchRequest()
        placeVisited = verifyDuplicityForRequest(request as! NSFetchRequest<NSFetchRequestResult>, withParameter: place.name) as? Place
        print(placeVisited)
        if placeVisited == nil {
            print(place.name)
            placeVisited = Place(context: context)
            placeVisited?.name = place.name
            placeVisited?.latitude = place.coordinate.latitude
            placeVisited?.longitude = place.coordinate.longitude
            placeVisited?.city = city
            placeVisited?.photoData = UIImagePNGRepresentation(pickedImage!) as NSData?
        }
        
        do {
            try context.save()
        } catch {
            print("There was a problem while saving to the database")
        }
        print(placeVisited)
        viewController.dismiss(animated: true, completion: nil)
        vc1.performFetchFor(vc1.fetchedResultsController)
        vc1.tableView.reloadData()
    }
    
    func verifyDuplicityForRequest(_ request: NSFetchRequest<NSFetchRequestResult>, withParameter parameter: String) -> NSManagedObject? {
        request.predicate = NSPredicate(format: "name = %@", parameter)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
//                assert(matches.count > 1, "database inconsistency")
                return matches[0] as? NSManagedObject
            } else {
                return nil
                
            }
        } catch let error {
            return nil
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
