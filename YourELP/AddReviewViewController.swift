//
//  AddReviewViewController.swift
//  YourELP
//
//  Created by Jackson Lu on 4/29/21.
//

import UIKit
import Cosmos
import ImagePicker

class AddReviewViewController: UIViewController, ImagePickerDelegate{
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("user selected images")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        selectedImages = images
        print("done button clicked")
        dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("Canceled all the images")
        dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var businessLabel: UILabel!
    @IBOutlet weak var descView: UITextView!
    @IBOutlet weak var cosmoView: CosmosView!
    @IBOutlet weak var addImageButton: UIButton! {
        didSet{
            addImageButton.backgroundColor = .clear
            addImageButton.layer.cornerRadius = 10
            addImageButton.layer.borderWidth = 2
            addImageButton.layer.borderColor = UIColor.orange.cgColor
        }
    }
    
    var userRating:Int = 0
    var selectedImages:[UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descView.text = "Write about your experience!"
        descView.textColor = UIColor.lightGray
        
        cosmoView.settings.fillMode = .full
        cosmoView.rating = 1
        cosmoView.didTouchCosmos = { rating in
            self.userRating = Int(rating)
            print(rating, "user selected rating")
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        if selectedImages != nil{ selectedImages = nil}
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pickImage(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.imageLimit = 5
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
}

extension AddReviewViewController:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descView.textColor == UIColor.lightGray {
            descView.text = nil
            descView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descView.text.isEmpty {
            descView.text = "Write about your experience!"
            descView.textColor = UIColor.lightGray
        }
    }
}
