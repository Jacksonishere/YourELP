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
import AVFoundation

protocol AddReviewDelegate: class {
    func finishedAdding()
    func finishedDeleting()
}


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
    @IBOutlet weak var deleteRevButton: UIButton!{
        didSet{
            deleteRevButton.layer.cornerRadius = 10
        }
    }
    
    var userRating:Double = 0
    var businessName:String = ""
    var categoryName:String = ""
    var businessID:String = ""
    var businessAddress = [String]()
    
    var selectedImages:[UIImage]?
    var editReviewImages:[UIImage]?
    var managedObjectContext: NSManagedObjectContext!
    
    weak var delegate: AddReviewDelegate?
    var audioPlayer:AVAudioPlayer!

    //use didset to set the other properties
    var reviewtoEdit:Review? {
        didSet{
            if let review = reviewtoEdit, let loadPhotos = review.photoURLS{
                editReviewImages = [UIImage]()
                
                for photoURLExtensions in loadPhotos{
                    let photoURL = applicationDocumentsDirectory.appendingPathComponent(photoURLExtensions)
                    if let addImage = UIImage(contentsOfFile: photoURL.path){
                        editReviewImages!.append(addImage)
                    }
                }
                businessName = review.businessName
                userRating = review.rating
                
                title = "Edit Your Review"
            }
        }
    }
    var didSelectImages = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reviewtoEdit != nil{
            print("addreview vc editing")
            deleteRevButton.isEnabled = true
            descView.text = reviewtoEdit!.reviewDesc
        }
        else{
            print("addreview vc adding")
            deleteRevButton.isEnabled = false
            deleteRevButton.alpha = 0.0

            descView.text = "Write about your experience!"
            descView.textColor = UIColor.lightGray
        }
        
        cosmoView.settings.fillMode = .full
        cosmoView.rating = userRating
        
        cosmoView.didTouchCosmos = { [weak self] rating in
            self!.userRating = rating
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
        view.gestureRecognizers?.removeAll()
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
            review.category = categoryName
            //set images nil for now
            review.businessID = businessID
            review.businessAddress = businessAddress
            review.photoURLS = nil
        }
        review.rating = userRating
        review.businessName = businessName
        if descView.text == "Write about your experience!"{
            descView.text = ""
        }
        else{
            review.reviewDesc = descView.text
        }
        
//        now if he has <= images.count, its fine because we just loop through that array and overwrite the image at location. delete the remaining if there are leftovers
//
//        but if he has > images.count, we over write all the urls. then starting from userdefault beginning, we write in newimages.count - oldimages.count
        //if images were selected
        if let selectedImages = selectedImages{
            //already has photos and the num of selected photos the same, just overwrite.
            //if its less than, we're gonna delete the last few images we didnt overwrite
            let docDIR = applicationDocumentsDirectory
            if let photoEXT = review.photoURLS{
                if selectedImages.count <= photoEXT.count {
                    for i in 0 ..< selectedImages.count{
                        saveImage(withImage: selectedImages[i], forURL: docDIR.appendingPathComponent(photoEXT[i]))
                    }
                    review.removePhotoFiles(numtoRv: photoEXT.count - selectedImages.count)
                    print("after removing extra", review.photoURLS!)
                }
                else{
                    //selected pics in edited greater than all photos in review. overwrite all then add the remaining.
                    for i in 0 ..< review.numPhotos{
                        saveImage(withImage: selectedImages[i], forURL: docDIR.appendingPathComponent(photoEXT[i]))
                    }
                    let diffNumPhotos = selectedImages.count - review.numPhotos
                    let photoIDBeg = Review.nextPhotoIDBeginning(numPhotos: diffNumPhotos)
                    for i in 0 ..< diffNumPhotos{
                        let filename = "Photo-\(photoIDBeg + i).jpg"
                        let dirPath = docDIR.appendingPathComponent(filename)
                        review.photoURLS!.append(filename)
                        saveImage(withImage: selectedImages[review.numPhotos + i], forURL: dirPath)
                    }
                }
              //new key is 6, puts for 4 and 5
            }
            else{
                let photoIDBeg = Review.nextPhotoIDBeginning(numPhotos: selectedImages.count)
                var fileNames = [String]()
                for i in 0 ..< selectedImages.count{
                    let filename = "Photo-\(photoIDBeg + i).jpg"
                    let dirPath = applicationDocumentsDirectory.appendingPathComponent(filename)
                    fileNames.append(filename)
                    saveImage(withImage: selectedImages[i], forURL: dirPath)
                }
                review.photoURLS = fileNames
            }
        }
        do {
            print("about to save context and show delay")
            try managedObjectContext.save()
            playSound()
            afterDelay(2.0) {
                hudView.hide()
                self.delegate?.finishedAdding()
//                self.navigationController?.popViewController(animated: true)
            }
        }
        catch {
            fatalError("failed to save!")
        }
    }
    

    @IBAction func presentDeleteAlert(_ sender: Any) {
        let deleteAlert = UIAlertController(title: "Delete Review", message: "Are you sure you want to delete this review?", preferredStyle: UIAlertController.Style.alert)

        deleteAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (action) in
            self!.deleteReview()
        }))

        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (action) in
            print("Cancelled")
        }))

        present(deleteAlert, animated: true, completion: nil)
    }
    
    func deleteReview(){
        guard let mainView = navigationController?.parent?.view else { return }
        let hudView = HudView.hud(inView: mainView, animated: true)
        hudView.text = "Deleted"
        
        reviewtoEdit!.removePhotoFiles(numtoRv: reviewtoEdit!.numPhotos)
        
        managedObjectContext.delete(reviewtoEdit!)
        do {
            try managedObjectContext.save()
            afterDelay(2.0) {
                hudView.hide()
                self.delegate?.finishedDeleting()
            }
        }
        catch {
            fatalError("error deleting review")
        }
    }
    
    func playSound(){
        let path = Bundle.main.path(forResource: "success.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
        catch {
            fatalError("Failed to load file")
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
                cell.configure(forImage: selectedImages![indexPath.row - 1])
                return cell
            }
            else{
                cell.configure(forImage: editReviewImages![indexPath.row - 1])
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("did end displaying called")
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addImageButtonCell", for: indexPath) as! addImageButtonCell
            cell.delegate = nil
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! photoCell
            cell.photoView.image = nil
        }
    }
    
}
