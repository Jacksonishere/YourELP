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
import AVFoundation

class MyReviewsViewController: UIViewController, MyReviewCellDelegate{
    func enlargeImage(forImage: UIImage) {
        performSegue(withIdentifier: "showImage", sender: forImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    var managedObjectContext: NSManagedObjectContext!
    var privateReviews = [Review]()
    var distanceDict = [String:Double]()
    var currAddressCoord:CLLocationCoordinate2D!
    
    var audioPlayer:AVAudioPlayer!


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

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let reviewsPerCate = fetchedResultsController.sections![section]
        return reviewsPerCate.numberOfObjects
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            cell.delegate = self
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
            self?.playDeletedSound()
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
            privateReviews = privateReviews.filter({ $0 !== review})
            distanceDict[review.businessID] = nil
            
            try managedObjectContext.save()
            afterDelay(2.0) {
                hudView.hide()
            }
        }
        catch {
            fatalError("error deleting review")
        }
    }
    
    func playDeletedSound(){
        let path = Bundle.main.path(forResource: "deleted.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
        catch {
            fatalError("Failed to load file")
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
        else if segue.identifier == "showImage"{
            let vc = segue.destination as! EnlargeImageViewController
            vc.showImage = sender as? UIImage
            
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
            let review = controller.object(at: newIndexPath!) as! Review
            privateReviews.append(review)
            distanceDict[review.businessID] = calculateDistance(from: currAddressCoord, to: CLLocationCoordinate2D(latitude: review.businessLat, longitude: review.businessLong))
            
            tableView.insertRows(at: [newIndexPath!], with: .fade)

        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)

        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? MyReviewCell {
                let review = controller.object(at: indexPath!) as! Review
                cell.configure(forReview: review, forDistance: distanceDict[review.businessID]!)
            }

        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)

        @unknown default:
            print("*** NSFetchedResults unknown type")
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
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
        tableView.endUpdates()
    }
}


