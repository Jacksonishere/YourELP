//
//  BusinessTableViewCell.swift
//  iOSProj
//
//  Created by Jackson Lu on 4/27/21.
//

import UIKit

class BusinessResultCell: UITableViewCell {

    var downloadTask: URLSessionDownloadTask?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var starsImage: UIImageView!
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(forbusiness business:Business, fordistance dist:Double){
        nameLabel.text = business.name
        phoneLabel.text = business.display_phone
        reviewsLabel.text = String(business.rating)
        var distMiles = String(dist)
        distMiles.append(" mi")
        distanceLabel.text = distMiles
        
        var displayAddress = ""
        displayAddress.displayAddress(address: business.location.display_address, separatedBy: "\n")
        addressLabel.text = displayAddress
        
        if let category = business.categories{
            if let businessPrice = business.price{
                categoryLabel.text = "\(businessPrice) · \(category[0].title)"
            }
            else{
                categoryLabel.text = category[0].title
            }
        }
        
        starsImage.image = Reviews.dict[business.rating]!
        
        if let imageUrl = URL(string: business.image_url) {
          downloadTask = restaurantImage.loadImage(url: imageUrl)
        }
    }

}
