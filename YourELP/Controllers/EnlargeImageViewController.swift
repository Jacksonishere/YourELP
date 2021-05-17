//
//  EnlargeImageViewController.swift
//  YourELP
//
//  Created by Jackson Lu on 5/16/21.
//

import UIKit

class EnlargeImageViewController: UIViewController {

    deinit {
        print("destroying enlargeimage")
    }
    @IBOutlet weak var imageView: UIImageView!
    var showImage:UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        imageView.image = showImage
    }
}
