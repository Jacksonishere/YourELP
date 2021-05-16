//
//  addImageButtonCell.swift
//  YourELP
//
//  Created by Jackson Lu on 4/30/21.
//

import UIKit

protocol addImageButtonDelegate: class {
    func userDidTap()
}

class addImageButtonCell: UICollectionViewCell {
    
    weak var delegate: addImageButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        delegate?.userDidTap()
    }
    
}
