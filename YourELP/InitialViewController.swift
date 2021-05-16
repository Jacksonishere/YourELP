//
//  InitialViewController.swift
//  YourELP
//
//  Created by Jackson Lu on 5/14/21.
//

import UIKit
import CoreData
import CoreLocation
class InitialViewController: UIViewController {

    
    var hasCurrAddy = false
    var currentAddy:String?
    var currAddyCoord:CLLocationCoordinate2D?
    
    var managedObjectContext: NSManagedObjectContext!

    //MARK: - Current Address View Stuff
    @IBOutlet weak var CurrentAddress: UIView!
    @IBOutlet weak var currentAddressLabel: UILabel!
    
    //MARK: - Enter New Address View Stuff
    @IBOutlet weak var EnterAddress: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var newAddressContinueButton: UIButton!
    var newAddress:CLPlacemark?
    
    func checkForAddress(){
        if let currAddress = UserDefaults.standard.string(forKey: "address"){
            currentAddressLabel.text = currAddress
            
            hasCurrAddy = true
            let longtitude = UserDefaults.standard.float(forKey: "addressLong")
            let latitude = UserDefaults.standard.float(forKey: "addressLat")
            let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longtitude))
            currentAddy = currAddress
            currAddyCoord = coordinates
        }
        if !hasCurrAddy{
            CurrentAddress.isHidden = true
        }
        else{
            EnterAddress.isHidden = true
        }
    }
    
    var loadedOnce = false
    override func viewWillAppear(_ animated: Bool) {
        if !loadedOnce{
            loadedOnce.toggle()
        }
        else{
            CurrentAddress.isHidden = false
            hasCurrAddy = true
            currentAddressLabel.text = currentAddy
            newAddressContinueButton.isEnabled = false
            addressTextField.text = nil
            EnterAddress.isHidden = true
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForAddress()
    }
    
    
    @IBAction func showEnter(_ sender: Any) {
        if hasCurrAddy{
            UIView.animate(withDuration: 0.3){
                self.EnterAddress.isHidden = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearch" || segue.identifier == "newAddress"{
            let tabVC = segue.destination as! UITabBarController
            let searchVC = tabVC.viewControllers![0] as! UINavigationController
            let reviewVC = tabVC.viewControllers![1] as! UINavigationController
            let destinationVC = searchVC.viewControllers.first as! SearchViewController
            let otherVC = reviewVC.viewControllers.first as! MyReviewsViewController
            
            destinationVC.currAddress = currentAddy
            destinationVC.currAddressCoord = currAddyCoord
            
            otherVC.currAddressCoord = currAddyCoord
            
            destinationVC.managedObjectContext = managedObjectContext
            otherVC.managedObjectContext = managedObjectContext
        }
    }
    
    @IBAction func NewlyEntered(_ sender: Any) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(addressTextField.text!) { (placemarks, error) in
            guard let placemarks = placemarks, let placemark = placemarks.first
            else {
                let alert = UIAlertController(
                    title: "Address Is Invalid",
                    message: "Entered Address Is Invalid. Try Again!",
                    preferredStyle: .alert)
            
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.addressTextField.text = nil
                    self.newAddressContinueButton.isEnabled = false
                }
                alert.addAction(okAction)
            
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.newAddress = placemark
            
            let newAddressStr = String(forPlacemark: placemark)
            
//            let newAddressLat = placemark.location!.coordinate.latitude
//            let newAddressLong = placemark.location!.coordinate.longitude
            
            let addressCord = placemark.location!.coordinate
            self.currAddyCoord = addressCord
            self.currentAddy = newAddressStr
            
            //store into userdefaults defaults
            UserDefaults.standard.setValue(newAddressStr, forKey: "address")
            UserDefaults.standard.setValue(addressCord.latitude, forKey: "addressLat")
            UserDefaults.standard.setValue(addressCord.longitude, forKey: "addressLong")
            
            self.performSegue(withIdentifier: "newAddress", sender: nil)
        }
    }
}

extension InitialViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
    
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
      
        if newText.isEmpty{
        newAddressContinueButton.isEnabled = false
        }
        else {
            newAddressContinueButton.isEnabled = true
        }
            return true
        }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        newAddressContinueButton.isEnabled = false
        return true
    }
}
