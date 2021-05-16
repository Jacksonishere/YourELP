//
//  photoCell.swift
//  YourELP
//
//  Created by Jackson Lu on 4/30/21.
//

import UIKit

class photoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView!{
        didSet{
            photoView.layer.cornerRadius = 10
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
//        photoView.image = nil
    }
    
    func configure(forImage image:UIImage){
        photoView.image = image
    }
}
