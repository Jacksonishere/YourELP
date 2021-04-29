//
//  MapViewController.swift
//  iOSProj
//
//  Created by Jackson Lu on 4/28/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var business:Business!
    var reviewsResultArray = [review]()
    
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?
        
    override func viewDidLoad() {
        super.viewDidLoad()
//        mapView.addAnnotation(business.coordinates)
//        zoomInToBusiness()
        performSearch()
    }
        
//    func zoomInToBusiness(){
//        let region = MKCoordinateRegion(
//            center: business.coordinates.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        mapView.setRegion(mapView.regionThatFits(region), animated: true)
//    }
    
    
    func yelpURL() -> URL {
        let urlString = "https://api.yelp.com/v3/businesses/\(business.id)/reviews"
        let url = URL(string: urlString)
        return url!
    }
    func parse(data: Data) -> [review] {
        print(data, "json data")
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(YelpReviewArray.self, from: data)
            return result.reviews
        }
        catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func performSearch() {
        dataTask?.cancel()
        isLoading = true
        tableView.reloadData()

        hasSearched = true
        reviewsResultArray = []
        
        let apiKey = "uVq481uD0mBvTkk3v4H62JOEr6_IMu_A0gSff2Fe_3xZf9u5z2aomsyqhmexTnci2L7zAOh747X55q-FPQ29zEg3mre-WVF5s1_pGi_w2m6saDxfQwKmUcHFBp5_YHYx"
        
        let url = yelpURL()
        //insert api key to request
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        dataTask = session.dataTask(with: request) {data, response, error in

            if let error = error as NSError?, error.code == -999 {
                return
            }
            else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    self.reviewsResultArray = self.parse(data: data)
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                }
            }
            else{
                print("Failure! \(response!)")
            }
            DispatchQueue.main.async {
                self.hasSearched = false
                self.isLoading = false
                self.tableView.reloadData()
            }
        }
        dataTask?.resume()
    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1 + 1
        }
        else if !hasSearched {
            return 0 + 1
        }
        else if reviewsResultArray.count == 0 {
            return 1 + 1
        }
        else {
            return reviewsResultArray.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell") as! MapCell
            cell.configure(forAnnotation: business.coordinates)
            cell.selectionStyle = .none
            return cell
        }
        else{
            if isLoading {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
                let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
                spinner.startAnimating()
                return cell
            }
            else if reviewsResultArray.count == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "NoReviewCell", for: indexPath)
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewResultCell", for: indexPath) as! ReviewResultCell
                let reviewResult = reviewsResultArray[indexPath.row - 1]
                cell.selectionStyle = .none
                cell.configure(forReview: reviewResult)
                return cell
            }
        }
    }
    
    
}
//func checkLocationPermission(){
//    let authStatus = locationManager.authorizationStatus
//    if authStatus == .notDetermined {
//        locationManager.requestWhenInUseAuthorization()
//        return
//    }
//    if authStatus == .denied || authStatus == .restricted {
//        showLocationServicesDeniedAlert()
//        return
//    }
//    mapView.addAnnotation(business.coordinates)
//    zoomInToBusiness()
//}
//
//func showLocationServicesDeniedAlert() {
//    let alert = UIAlertController(
//        title: "Location Services Disabled",
//        message: "Please enable location services for this app in Settings.",
//        preferredStyle: .alert)
//
//    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
//        self.navigationController?.popViewController(animated: true)
//    }
//    alert.addAction(okAction)
//
//    present(alert, animated: true, completion: nil)
//
//}
