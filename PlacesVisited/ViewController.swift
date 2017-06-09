//
//  ViewController.swift
//  PlacesVisited
//
//  Created by Guillermo Diaz on 6/3/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKLoginKit

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = AppDelegate.viewContext
    var fetchedResultsController: NSFetchedResultsController<Country> = NSFetchedResultsController()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = countryListFetchedResultsController()
//        deleteAllCoreData()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handlePresentAddPhotoVC))
        
    }
    
    func deleteAllCoreData() {
        let countries = fetchedResultsController.fetchedObjects
        for country in countries! {
            context.delete(country)
            do {
                try context.save()
            } catch {
                print("There was a problem while saving to the database")
            }
        }
    }
    
    func countryListFetchedResultsController() -> NSFetchedResultsController<Country> {
        let fetchedResultController = NSFetchedResultsController(fetchRequest: countryFetchRequest(),
                                                                 managedObjectContext: context,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        
        performFetchFor(fetchedResultController)
        
        return fetchedResultController
    }
    
    func performFetchFor(_ fetchedResultController: NSFetchedResultsController<Country>) {
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    func countryFetchRequest() -> NSFetchRequest<Country> {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = []
        //        fetchRequest.predicate = NSPredicate(format: "pin = %@", self.pinSelected)
        
        return fetchRequest
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let countries = fetchedResultsController.fetchedObjects else { return 0 }
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let countries = fetchedResultsController.fetchedObjects else { return "" }
        let country = countries[section]
        return country.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let countries = fetchedResultsController.fetchedObjects else { return 0 }
        guard let numberofRows = countries[section].cities?.count else { return 0 }
        return numberofRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let country = fetchedResultsController.object(at: indexPath)
        let citiesArray = country.cities?.allObjects
        let city: City = citiesArray?[indexPath.item] as! City
        cell.backgroundColor = .blue
        cell.textLabel?.text = city.name
        return cell
    }
    
    func handlePresentAddPhotoVC() {
        let nc = UINavigationController(rootViewController: AddPhotoController())
        present(nc, animated: true)
    }
    
    func handleLogout() {
        appDelegate.handleLogout(sender: self)
    }
    
}
