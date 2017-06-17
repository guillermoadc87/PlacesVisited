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

class PhotoCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var cityName: String? = nil
    let context = AppDelegate.viewContext
    var selectionOn: Bool = false
    var cellsToDelete: [PlaceCell] = []
    var fetchedResultsController: NSFetchedResultsController<Place> = NSFetchedResultsController()
    var favoriteController: FavoritePhotoController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController = countryListFetchedResultsController()
        
        // Register cell classes
        self.collectionView!.register(PlaceCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleFavorite(gestureReconizer:))))
        self.collectionView?.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(handleSelection))
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
        
        if !selectionOn {
            originalFrame = cell.superview?.convert(cell.frame, to: nil)
            
            fullScreenImageView.frame = originalFrame!
            fullScreenImageView.image = cell.imageView.image
            
            view.addSubview(fullScreenImageView)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.fullScreenImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            }, completion: { didComplete in
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(self.handlePosting))
            })
        } else {
            print("Selection Mode")
            if !cellsToDelete.contains(cell) {
                print("Photo Added")
                cell.selected(true)
                cellsToDelete.append(cell)
            } else {
                print("Photo Deleted")
                let index = cellsToDelete.index(of: cell)
                if let index = index {
                    cell.selected(false)
                    cellsToDelete.remove(at: index)
                }
            }
        }
    }
    
    
    func handleImageResizing() {
        UIView.animate(withDuration: 0.5, animations: {
            self.fullScreenImageView.frame = self.originalFrame!
        }, completion: { didComplete in
            self.fullScreenImageView.removeFromSuperview()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(self.handleSelection))
        })
    }
    
    func handlePosting() {
        let postVC = PostViewController()
        postVC.place = selectedPlace
        let postNavController = UINavigationController(rootViewController: postVC)
        present(postNavController, animated: true, completion: nil)
    }
    
    func handleSelection() {
        selectionOn = !selectionOn
        if selectionOn {
            let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleSelection))
            let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDeletion))
            navigationItem.rightBarButtonItems = [delete, cancel]
        } else {
            let select = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(handleSelection))
            navigationItem.rightBarButtonItems = [select]
            for cell in cellsToDelete {
                cell.selected(false)
            }
            cellsToDelete.removeAll()
        }
        
    }
    
    func handleDeletion() {
        for cell in cellsToDelete {
            fetchedResultsController.managedObjectContext.delete(cell.place!)
            do {
                try context.save()
            } catch {
                print("There was a problem while saving to the database")
            }
        }
        cellsToDelete.removeAll()
    }
    
    func handleFavorite(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == .began {
            let p = gestureReconizer.location(in: self.collectionView)
            let indexPath = self.collectionView?.indexPathForItem(at: p)
            
            if let index = indexPath {
                let cell = self.collectionView?.cellForItem(at: index) as! PlaceCell
                // do stuff with your cell, for example print the indexPath
                cell.favoriteView.isHidden = !cell.favoriteView.isHidden
                cell.place?.isFavorite = cell.favoriteView.isHidden
                
                do {
                    try context.save()
                    favoriteController?.performFetchFor((favoriteController?.fetchedResultsController)!)
                    favoriteController?.collectionView?.reloadData()
                } catch {
                    print("There was a problem while saving to the database")
                }
            }
        }
    }
}

extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .delete:
            if let indexPath = indexPath {
                collectionView?.deleteItems(at: [indexPath])
            }
            break
        default:
            break
        }
    }
}










