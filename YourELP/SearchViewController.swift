//
//  ViewController.swift
//  iOSProj
//
//  Created by Jackson Lu on 4/20/21.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var businessResults = [Business]()
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        
    }
    
    func yelpURL(searchText: String) -> URL {
        print(searchText, "searched text")
        let encodedBusiness = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let address = "brighton beach"
        let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        //right now urlstring brighton beach but will change
        let urlString = "https://api.yelp.com/v3/businesses/search?term=\(encodedBusiness)&location=\(encodedAddress)"
        let url = URL(string: urlString)
        return url!
    }

    func parse(data: Data) -> [Business] {
        print(data, "json data")
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(YelpResultArray.self, from: data)
            return result.businesses
        }
        catch {
            print("JSON Error: \(error)")
            return []
        }
    }
}

// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }

    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()

            hasSearched = true
            businessResults = []
            
            let apiKey = "uVq481uD0mBvTkk3v4H62JOEr6_IMu_A0gSff2Fe_3xZf9u5z2aomsyqhmexTnci2L7zAOh747X55q-FPQ29zEg3mre-WVF5s1_pGi_w2m6saDxfQwKmUcHFBp5_YHYx"
            
            let url = yelpURL(searchText: searchBar.text!)
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
                        self.businessResults = self.parse(data: data)
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
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        }
        else if !hasSearched {
            return 0
        }
        else if businessResults.count == 0 {
            return 1
        }
        else {
            return businessResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        else if businessResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "NothingFoundCell", for: indexPath)
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessResultCell", for: indexPath) as! BusinessResultCell
            let businessResult = businessResults[indexPath.row]
            cell.configure(forbusiness: businessResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMap", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap"{
            let viewcontroller = segue.destination as! MapViewController
            let locationNum = sender as! Int
            viewcontroller.business = businessResults[locationNum]
        }
    }
}


