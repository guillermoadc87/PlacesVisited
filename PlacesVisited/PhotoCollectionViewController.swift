//
//  PhotoCollectionViewController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/9/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class PhotoCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    var cityName: String? = nil
    let context = AppDelegate.viewContext
    var fetchedResultsController: NSFetchedResultsController<Place> = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController = countryListFetchedResultsController()
        
        // Register cell classes
        self.collectionView!.register(PlaceCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = .white
        
        navigationItem.title = cityName
    }
    
    func countryListFetchedResultsController() -> NSFetchedResultsController<Place> {
        let fetchedResultController = NSFetchedResultsController(fetchRequest: placeFetchRequest(),
                                                                 managedObjectContext: context,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        
        performFetchFor(fetchedResultController)
        
        return fetchedResultController
    }
    
    func performFetchFor(_ fetchedResultController: NSFetchedResultsController<Place>) {
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    func placeFetchRequest() -> NSFetchRequest<Place> {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "city.name = %@", self.cityName!)
        
        return fetchRequest
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let places = fetchedResultsController.fetchedObjects else { return 0 }
        return places.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlaceCell
        
        // Configure the cell
        let place = fetchedResultsController.object(at: indexPath)
        cell.place = place
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width/3, height: view.frame.size.width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    var originalFrame:CGRect?
    lazy var fullScreenImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleImageResizing)))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var selectedPlace: Place?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPlace = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.cellForItem(at: indexPath) as! PlaceCell
        originalFrame = cell.superview?.convert(cell.frame, to: nil)
        
        fullScreenImageView.frame = originalFrame!
        fullScreenImageView.image = cell.imageView.image
        
        view.addSubview(fullScreenImageView)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }, completion: { didComplete in
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(self.handlePosting))
        })
    }
    
    
    func handleImageResizing() {
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenImageView.frame = self.originalFrame!
        }, completion: { didComplete in
            self.fullScreenImageView.removeFromSuperview()
            self.navigationItem.rightBarButtonItem = nil
        })
        
    }
    
    func handlePosting() {
        let postVC = PostViewController()
        postVC.place = selectedPlace
        let postNavController = UINavigationController(rootViewController: postVC)
        present(postNavController, animated: true, completion: nil)
    }

}











