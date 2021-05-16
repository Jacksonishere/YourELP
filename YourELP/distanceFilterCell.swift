//
//  distanceFilterCell.swift
//  YourELP
//
//  Created by Jackson Lu on 5/16/21.
//

import UIKit

protocol distanceSelectedDelegate: class {
    func distanceSelected(forDistance: Double)
}

class distanceFilterCell: UITableViewCell {

    @IBOutlet var segmentedControl: UISegmentedControl!

    weak var delegate:distanceSelectedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        segmentedControl.addTarget(self, action: #selector(indexChange(_:)), for: .valueChanged)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func indexChange(_ sender: UISegmentedControl){
        if segmentedControl.selectedSegmentIndex == 0 {
            delegate?.distanceSelected(forDistance: 1)
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            delegate?.distanceSelected(forDistance: 2)
        }
        else if segmentedControl.selectedSegmentIndex == 2 {
            delegate?.distanceSelected(forDistance: 5)
        }
        else{
            delegate?.distanceSelected(forDistance: 10)
        }
    }
    
    func resetDistance(){
        self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
    }

}
