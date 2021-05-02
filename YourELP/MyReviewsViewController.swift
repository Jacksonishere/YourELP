//
//  MyReviewsViewController.swift
//  YourELP
//
//  Created by Jackson Lu on 4/30/21.
//

import UIKit
import CoreData

class MyReviewsViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext!
    var privateReviews = [Review]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("did i load at start?")
        fetchReviews()
    }
    
    func fetchReviews(){
        let fetchRequest = NSFetchRequest<Review>()
        fetchRequest.entity = Review.entity()

        let sort1 = NSSortDescriptor(key: "businessName", ascending: true)
        let sort2 = NSSortDescriptor(key: "rating", ascending: false)
        fetchRequest.sortDescriptors = [sort1, sort2]
        
        privateReviews = try! managedObjectContext.fetch(fetchRequest)
        for review in privateReviews{
            if review.photoURLS != nil{
                print(review.businessName, "and images", review.photoURLS!)
            }
            else{
                print(review.businessName, "and but no images")
            }
        }
    }
}
