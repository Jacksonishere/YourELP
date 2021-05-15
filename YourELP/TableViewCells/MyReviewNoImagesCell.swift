//
//  MyReviewNoImagesCell.swift
//  YourELP
//
//  Created by Jackson Lu on 5/5/21.
//

import UIKit
import Cosmos

class MyReviewNoImagesCell: UITableViewCell {

    @IBOutlet weak var businessName: UILabel!
    @IBOutlet weak var businessAddress: UILabel!
    @IBOutlet weak var myRating: CosmosView!
    @IBOutlet weak var myDesc: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myRating.settings.updateOnTouch = false
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(forReview review:Review, forDistance dist:Double){
        businessName.text = review.businessName
        myDesc.text = review.reviewDesc
        myRating.rating = review.rating
        
        var distMiles = String(dist)
        distMiles.append(" mi")
        distanceLabel.text = distMiles
        
        var businessAddressConvert = ""
        businessAddressConvert.displayAddress(address: review.businessAddress, separatedBy: "\n")
        businessAddress.text = businessAddressConvert
    }

}
