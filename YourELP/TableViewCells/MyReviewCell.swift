//
//  MyReviewCell.swift
//  YourELP
//
//  Created by Jackson Lu on 5/2/21.
//

import UIKit
import Cosmos

protocol MyReviewCellDelegate: class {
    func enlargeImage(forImage: UIImage)
}

class MyReviewCell: UITableViewCell {

    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var myRating: CosmosView!
    @IBOutlet weak var myDesc: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var businessAddress: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    deinit{
        print("destroying cell")
    }
    var reviewImages = [UIImage]()
    
    weak var delegate:MyReviewCellDelegate?
    
    override func prepareForReuse() {
        reviewImages = []
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myRating.settings.updateOnTouch = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(forReview review:Review, forDistance dist:Double){
        reviewImages.removeAll()
        businessName.text = review.businessName
        myDesc.text = review.reviewDesc
        myRating.rating = review.rating
        var businessAddressConvert = ""
        businessAddressConvert.displayAddress(address: review.businessAddress, separatedBy: "\n")
        businessAddress.text = businessAddressConvert
        
        var distMiles = String(dist)
        distMiles.append(" mi")
        distanceLabel.text = distMiles

        
        if let photoNames = review.photoURLS{
            for photoName in photoNames{
                let photoURL = applicationDocumentsDirectory.appendingPathComponent(photoName)
                if let addImage = UIImage(contentsOfFile: photoURL.path){
                    reviewImages.append(addImage)
                }
            }
            collectionView.reloadData()
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.enlargeImage(forImage: reviewImages[indexPath.row])
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
