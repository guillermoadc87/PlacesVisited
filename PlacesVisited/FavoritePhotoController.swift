//
//  AddPhotoController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/4/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class FavoritePhotoController: UICollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    
    let context = AppDelegate.viewContext
    var fetchedResultsController: NSFetchedResultsController<Place> = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController = countryListFetchedResultsController()
        self.collectionView!.register(PlaceCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = .white
        navigationItem.title = "Favorites"
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
        fetchRequest.predicate = NSPredicate(format: "isFavorite != false")
        
        return fetchRequest
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
    
}
