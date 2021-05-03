//
//  MyReviewCell.swift
//  YourELP
//
//  Created by Jackson Lu on 5/2/21.
//

import UIKit
import Cosmos

class MyReviewCell: UITableViewCell {

    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var myRating: CosmosView!
    @IBOutlet weak var myDesc: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var reviewImages = [UIImage]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myRating.settings.updateOnTouch = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(forReview review:Review){
        businessName.text = review.businessName
        myDesc.text = review.reviewDesc
        myRating.rating = review.rating
        
        if let photoNames = review.photoURLS{
            for photoName in photoNames{
                let photoURL = applicationDocumentsDirectory.appendingPathComponent(photoName)
                if let addImage = UIImage(contentsOfFile: photoURL.path){
                    reviewImages.append(addImage)
                }
            }
        }
        collectionView.reloadData()
    }
}

extension MyReviewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        reviewImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! photoCell
        cell.configure(forImage: reviewImages[indexPath.row])
        return cell
    }
    
    
}
