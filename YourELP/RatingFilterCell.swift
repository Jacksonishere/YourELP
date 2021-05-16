//
//  RatingFilterCell.swift
//  YourELP
//
//  Created by Jackson Lu on 5/15/21.
//

import UIKit
import Cosmos

protocol ratingSelectedDelegate: class {
    func ratingSelected(forRating: Double)
}

class RatingFilterCell: UITableViewCell {

    @IBOutlet var cosmosView:CosmosView!
    
    weak var delegate: ratingSelectedDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cosmosView.settings.fillMode = .full
        
        cosmosView.didTouchCosmos = { [weak self] rating in
            self!.delegate?.ratingSelected(forRating: rating)
        }
    }
    
    func resetStars(){
        cosmosView.rating = 5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
