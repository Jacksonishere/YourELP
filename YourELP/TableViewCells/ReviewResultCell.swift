//
//  ReviewResultCell.swift
//  YourELP
//
//  Created by Jackson Lu on 4/29/21.
//

import UIKit

class ReviewResultCell: UITableViewCell {
    var downloadTask: URLSessionDownloadTask?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var reviewStars: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var reviewDesc: UILabel!
    
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
    }
    
    func configure(forReview review:review){
        nameLabel.text = review.user.name
        reviewDesc.text = review.text
        
        var currDate = review.time_created
        currDate.getTimeStamp(fixTimestamp: currDate)
        timeStamp.text = currDate
        
        reviewStars.image = Reviews.dict[review.rating]!
    
        if review.user.image_url != nil, let imageUrl = URL(string: review.user.image_url!){
            downloadTask = userImage.loadImage(url: imageUrl)
        }
        else{
            userImage.image = #imageLiteral(resourceName: "default")
        }
    }

}
