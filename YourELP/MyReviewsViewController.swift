//
//  MyReviewsViewController.swift
//  YourELP
//
//  Created by Jackson Lu on 4/30/21.
//

import UIKit
import Cosmos
import CoreData
import CoreLocation

class MyReviewsViewController: UIViewController{

    var managedObjectContext: NSManagedObjectContext!
    var privateReviews = [Review]()
    var filteredReviews = [Review]()
    var filteredCategory = ""
    var distanceDict = [String:Double]()
    var currAddressCoord:CLLocationCoordinate2D!
    
    var hasFiltered = false

    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double{
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        var distance = from.distance(from: to)
        
        distance = (distance * 0.00621371192)
        distance.round()
        distance = distance/10
        
        return distance
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<Review> = {
        
        let fetchRequest = NSFetchRequest<Review>()
        fetchRequest.entity = Review.entity()

        do {
            privateReviews = try managedObjectContext.fetch(fetchRequest)
            for review in privateReviews{
                distanceDict[review.businessID] = calculateDistance(from: currAddressCoord, to: CLLocationCoordinate2D(latitude: review.businessLat, longitude: review.businessLong))
            }
        }
        catch {
            fatalError("could not fetch")
        }
        
        let sort1 = NSSortDescriptor(key: "category", ascending: true)
        let sort2 = NSSortDescriptor(key: "rating", ascending: true)
        fetchRequest.sortDescriptors = [sort1, sort2]

        fetchRequest.fetchBatchSize = 20

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: nil)

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
            if fetchedResultsController.sections!.count == 0{
                filterButton.isEnabled = false
            }
        }
        catch{
            fatalError("Failed to fetch")
        }
    }
}

extension MyReviewsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !hasFiltered{
            return fetchedResultsController.sections!.count
        }
        else{
            return 1
        }
    }

     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !hasFiltered{
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.name
        }
        else{
            return filteredCategory
        }
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasFiltered{
            let reviewsPerCate = fetchedResultsController.sections![section]
            return reviewsPerCate.numberOfObjects
        }
        else{
            return filteredReviews.count
        }
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !hasFiltered{
            let myReview = fetchedResultsController.object(at: indexPath)
            
            if myReview.numPhotos == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewNoImagesCell", for: indexPath) as! MyReviewNoImagesCell
                cell.configure(forReview: myReview, forDistance: distanceDict[myReview.businessID]!)
                cell.selectionStyle = .none
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewCell", for: indexPath) as! MyReviewCell
                cell.configure(forReview: myReview, forDistance: distanceDict[myReview.businessID]!)
                cell.selectionStyle = .none
                return cell
            }
        }
        else{
            let myReview = filteredReviews[indexPath.row]
            if myReview.numPhotos == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewNoImagesCell", for: indexPath) as! MyReviewNoImagesCell
                cell.configure(forReview: myReview, forDistance: distanceDict[myReview.businessID]!)
                cell.selectionStyle = .none
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MyReviewCell", for: indexPath) as! MyReviewCell
                cell.configure(forReview: myReview, forDistance: distanceDict[myReview.businessID]!)
                cell.selectionStyle = .none
                return cell
            }
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
            
            privateReviews = privateReviews.filter({ $0 !== review})
            distanceDict[review.businessID] = nil

            print("reviews count after delete \(privateReviews.count)")
            if privateReviews.count == 0{
                filterButton.isEnabled = false
            }
            afterDelay(2.0) {
                hudView.hide()
//                for key in imageCache.current.imageDict{
//                    print(key.key, "current key")
//                }
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
        else if segue.identifier == "filter"{
            let vc = segue.destination as! FilterViewController
            for category in fetchedResultsController.sections!{
                vc.filterCategories.append(category.name)
            }
            vc.delegate = self
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
            let review = controller.object(at: newIndexPath!) as! Review
            
            print("reviews count after insert\(privateReviews.count)")
            privateReviews.append(review)
            distanceDict[review.businessID] = calculateDistance(from: currAddressCoord, to: CLLocationCoordinate2D(latitude: review.businessLat, longitude: review.businessLong))
            
            filterButton.isEnabled = true
            
            if !hasFiltered{
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            }

        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)

        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? MyReviewCell {
                let review = controller.object(at: indexPath!) as! Review
                cell.configure(forReview: review, forDistance: distanceDict[review.businessID]!)
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

extension MyReviewsViewController:filtersSelectedDelegate{
    func filtersSelected(forFilterCategory: String, forFilterRating: Double, forFilterDistance: Double?) {
        
        hasFiltered = true
        
        let fetchRequest = NSFetchRequest<Review>()
        fetchRequest.entity = Review.entity()
        
        fetchRequest.predicate = NSPredicate(format: "category == %@", forFilterCategory)
        
//        let categoryPredicate = NSPredicate(format: "category == %@", forFilterCategory)
//        let ratingPredicate = NSPredicate(format: "NSNumber(value: rating) >= %@", NSNumber(value: forFilterRating))
//        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [categoryPredicate, ratingPredicate])
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            filteredReviews = results
        }
        catch let error {
            print(error.localizedDescription)
        }
        
        tableView.reloadData()

        print("filter by cat \(forFilterCategory), by rating \(forFilterRating), by distance \(forFilterDistance ?? 0)")
    }
}


