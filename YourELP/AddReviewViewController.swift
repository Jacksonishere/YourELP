//
//  AddReviewViewController.swift
//  YourELP
//
//  Created by Jackson Lu on 4/29/21.
//

import UIKit
import CoreData
import Cosmos
import ImagePicker

class AddReviewViewController: UIViewController, ImagePickerDelegate, addImageButtonDelegate{
    
    deinit {
        print("destroyed addreview viewcontroler")
    }
    func userDidTap() {
        presentImageController()
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("user selected images")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        didSelectImages = true
        selectedImages = images
        collectionView.reloadData()
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

    @IBOutlet weak var collectionView: UICollectionView!
    
    var userRating:Double = 0
    var businessName:String = ""
    
    var selectedImages:[UIImage]?
    var editReviewImages:[UIImage]?
    var managedObjectContext: NSManagedObjectContext!
    //use didset to set the other properties
    var reviewtoEdit:Review? {
        didSet{
            if let review = reviewtoEdit, let loadPhotos = review.photoURLS{
                for photoURL in loadPhotos{
                    let addImage = UIImage(contentsOfFile: URL(string: photoURL)!.path)
                    editReviewImages?.append(addImage!)
                }
                collectionView.reloadData()
                businessName = review.restName
                userRating = review.rating
                descView.text = review.reviewDesc
            }
        }
    }
    var didSelectImages = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descView.text = "Write about your experience!"
        descView.textColor = UIColor.lightGray
        
        cosmoView.settings.fillMode = .full
        cosmoView.rating = userRating
        
        cosmoView.didTouchCosmos = { rating in
            self.userRating = rating
//            print(rating, "user selected rating")
        }
        businessLabel.text = businessName
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        if selectedImages != nil{ selectedImages = nil}
        if editReviewImages != nil{ editReviewImages = nil}
        collectionView = nil
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        guard let mainView = navigationController?.parent?.view else { return }
        let hudView = HudView.hud(inView: mainView, animated: true)
        let review:Review
        //segued here with a review to edit.
        if let editReview = reviewtoEdit{
            hudView.text = "Updated"
            review = editReview
        }
        //else wasn't a segue, we create a new review we will add to coredata
        else {
            hudView.text = "Added"
            review = Review(context: managedObjectContext)
            //set images nil for now
            review.photoURLS = nil
        }
        review.rating = userRating
        review.restName = businessName
        review.reviewDesc = descView.text
        
        
//        now if he has <= images.count, its fine because we just loop through that array and overwrite the image at location. delete the remaining if there are leftovers
//
//        but if he has > images.count, we over write all the urls. then starting from userdefault beginning, we write in newimages.count - oldimages.count
        //if images were selected
        if let selectedImages = selectedImages{
            //already has photos and the num of selected photos the same, just overwrite.
            if let reviewPhotos = review.photoURLS{
                if reviewPhotos.count <= selectedImages.count {
                    for i in 0 ..< selectedImages.count{
                        saveImage(withImage: selectedImages[i], forURL: URL(string: reviewPhotos[i])!)
                    }
                    review.removePhotoFiles(numtoRv: selectedImages.count - reviewPhotos.count)
                }
                else{
                    //selected pics in edited greater than all photos in review. overwrite all then add the remaining.
                    for i in 0 ..< review.photoURLS!.count{
                        saveImage(withImage: selectedImages[i], forURL: URL(string: review.photoURLS![i])!)
                    }
                    let photoIDBeg = Review.nextPhotoIDBeginning(setNextBeg: selectedImages.count)
                    let currPhotosCount = review.photoURLS!.count
                    for i in 0 ..< selectedImages.count - currPhotosCount{
                        let filename = "Photo-\(photoIDBeg + i).jpg"
                        let dirPath = applicationDocumentsDirectory.appendingPathComponent(filename)
                        review.photoURLS!.append(dirPath.absoluteString)
                        saveImage(withImage: selectedImages[i], forURL: dirPath)
                    }
                }
              
            }
            else{
                let photoIDBeg = Review.nextPhotoIDBeginning(setNextBeg: selectedImages.count)
                var stringURLs = [String]()
                for i in 0 ..< selectedImages.count{
                    let filename = "Photo-\(photoIDBeg + i).jpg"
                    let dirPath = applicationDocumentsDirectory.appendingPathComponent(filename)
                    stringURLs.append(dirPath.absoluteString)
                    saveImage(withImage: selectedImages[i], forURL: dirPath)
                }
            }
        }
    }
    
    func saveImage(withImage image:UIImage, forURL url:URL){
        if let data = image.jpegData(compressionQuality: 0.5) {
            do {
                try data.write(to: url, options: .atomic)
            }
            catch {
                print("Error writing file: \(error)")
            }
        }
    }
    
    func presentImageController() {
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

extension AddReviewViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if not editing review and didnt select images
//        if reviewtoEdit == nil, !didSelectImages || reviewtoEdit != nil, reviewtoEdit!.photoURLS == nil, !didSelectImages{
//            return 1
//        }
//        else if reviewtoEdit != nil, !didSelectImages{
//            return 1 +
//        }
        if didSelectImages{
            return 1 + selectedImages!.count
        }
        else if editReviewImages != nil{
            return 1 + editReviewImages!.count
        }
        else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addImageButtonCell", for: indexPath) as! addImageButtonCell
            cell.delegate = self
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! photoCell
            if didSelectImages{
                cell.photoView.image = selectedImages![indexPath.row - 1]
                return cell
            }
            else{
                cell.photoView.image = editReviewImages![indexPath.row - 1]
                return cell
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0{
            return CGSize(width: 55, height: 50)
        }
        else{
            return CGSize(width: 128, height: 128)
        }
    }
    
}
