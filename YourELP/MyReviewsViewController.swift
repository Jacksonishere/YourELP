//
//  MyReviewsViewController.swift
//  YourELP
//
//  Created by Jackson Lu on 4/30/21.
//

import UIKit
import Cosmos
import CoreData

class MyReviewsViewController: UIViewController{

    var managedObjectContext: NSManagedObjectContext!
    var privateReviews = [Review]()

    @IBOutlet weak var tableView: UITableView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Review> = {
        
        let fetchRequest = NSFetchRequest<Review>()
        fetchRequest.entity = Review.entity()

        let sort1 = NSSortDescriptor(key: "category", ascending: true)
        let sort2 = NSSortDescriptor(key: "rating", ascending: true)
        fetchRequest.sortDescriptors = [sort1, sort2]

        fetchRequest.fetchBatchSize = 20

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "MyReviews")

        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    deinit {
        fetchedResultsController.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchReviews()
    }
    
    func fetchReviews(){
        do{
            try fetchedResultsController.performFetch()
        }
        catch{
            fatalError("Failed to fetch")
        }
    }
}

extension MyReviewsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }

     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 4, y: tableView.sectionHeaderHeight - 14, width: view.frame.width, height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 13)

        label.text = self.tableView(tableView, titleForHeaderInSection: section)

//      label.textColor = UIColor(white: 1.0, alpha: 0.6)
        label.backgroundColor = UIColor.clear

        let separatorRect = CGRect(x: 15, y: tableView.sectionHeaderHeight - 0.5, width: tableView.bounds.size.width - 15, height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor

        let viewRect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.sectionHeaderHeight)
        
        let view = UIView(frame: viewRect)
        view.addSubview(label)
        view.addSubview(separator)
        return view
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let reviewsPerCate = fetchedResultsController.sections![section]
        return reviewsPerCate.numberOfObjects
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myReview = fetchedResultsController.object(at: indexPath)
        
        if myReview.numPhotos == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewNoImagesCell", for: indexPath) as! MyReviewNoImagesCell
            cell.configure(forReview: myReview)
            cell.selectionStyle = .none
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewCell", for: indexPath) as! MyReviewCell
            cell.configure(forReview: myReview)
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let reviewForCell = fetchedResultsController.object(at: indexPath)
        let editReview = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.editReview(forReview: reviewForCell)
            completionHandler(true)
        }
        editReview.backgroundColor = .systemBlue
        
        let removeReview = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteReview(forReview: reviewForCell)
            completionHandler(true)
        }
        removeReview.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [editReview, removeReview])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func editReview(forReview review:Review){
        performSegue(withIdentifier: "editReview", sender: review)
    }
    
    func deleteReview(forReview review:Review){
        guard let mainView = navigationController?.parent?.view else { return }
        let hudView = HudView.hud(inView: mainView, animated: true)
        hudView.text = "Deleted"
        
        review.removePhotoFiles(numtoRv: review.numPhotos)
        
        managedObjectContext.delete(review)
        do {
            try managedObjectContext.save()
            afterDelay(2.0) {
                hudView.hide()
                for key in imageCache.current.imageDict{
                    print(key.key, "current key")
                }
            }
        }
        catch {
            fatalError("error deleting review")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editReview"{
            let vc = segue.destination as! AddReviewViewController
            if let editReview = sender{
                print("editing review")
                vc.reviewtoEdit = editReview as? Review
                vc.managedObjectContext = managedObjectContext
            }
        }
    }
}

// MARK: - NSFetchedResultsController Delegate Extension
extension MyReviewsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)

        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)

        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? MyReviewCell {
                let review = controller.object(at: indexPath!) as! Review
                cell.configure(forReview: review)
            }

        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)

        @unknown default:
            print("*** NSFetchedResults unknown type")
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        @unknown default:
            print("*** NSFetchedResults unknown type")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}



