//
//  MandelbrotExplorerRootViewControllerTableViewController.swift
//  MandelbrotExplorer iPad
//
//  Created by Jae Seung Lee on 10/4/20.
//  Copyright © 2020 Jae Seung Lee. All rights reserved.
//

import UIKit
import CoreData

class MandelbrotExplorerRootViewControllerTableViewController: UITableViewController {
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<MandelbrotEntity>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFetchedResultsController()
    }
    
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<MandelbrotEntity> = setupFetchRequest()
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "mandelbrotEntities")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            NSLog("Compounds cannot be fetched: \(error)")
            self.showAlert(message: "Compounds cannot be fetched.")
        }
    }
    
    func setupFetchRequest() -> NSFetchRequest<MandelbrotEntity> {
        let fetchRequest: NSFetchRequest<MandelbrotEntity> = MandelbrotEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }
    
    private func showAlert(message: String) -> Void {
        let alert = UIAlertController(title: "Fatal Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Seen", style: .default, handler: nil))
        present(alert, animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mandelbrotEntity = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RootViewControllerTableViewCell", for: indexPath)
        cell.textLabel!.text = "\(mandelbrotEntity.description)"
        
        if let imageData = mandelbrotEntity.image {
            cell.imageView?.image = UIImage(data: imageData as Data, scale: 10.0)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mandelbrotEntity = fetchedResultsController.object(at: indexPath)
        let detailViewNavigationController = splitViewController?.viewControllers.last as? UINavigationController
        
        let detailViewController = setupDetailViewController(for: mandelbrotEntity)
        detailViewNavigationController?.popToRootViewController(animated: false)
        detailViewNavigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func setupDetailViewController(for mandelbrotEntity: MandelbrotEntity) -> MandelbrotExplorerExamineViewController {
        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "MandelbrotExamineViewController") as! MandelbrotExplorerExamineViewController
        detailViewController.dataController = dataController
        detailViewController.mandelbrotEntity = mandelbrotEntity
        return detailViewController
    }
    
    func delete(mandelbrotEntity: MandelbrotEntity) {
        dataController.viewContext.delete(mandelbrotEntity)
        
        do {
            try dataController.viewContext.save()
            NSLog("Saved in SolutionTableViewController.delete(mandelbrotEntity:)")
        } catch {
            NSLog("Error while saving in MandelbrotExplorerRootViewControllerTableViewController.delete(mandelbrotEntity:)")
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(mandelbrotEntity: fetchedResultsController.object(at: indexPath))
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension MandelbrotExplorerRootViewControllerTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let set = IndexSet(integer: sectionIndex)
        switch (type) {
        case .insert:
            tableView.insertSections(set, with: .fade)
        case .delete:
            tableView.deleteSections(set, with: .fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            NSLog("Unkown change type: \(type)")
            self.showAlert(message: "Unkown change type: \(type)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
