//
//  FilterViewController.swift
//  YourELP
//
//  Created by Jackson Lu on 5/14/21.
//

import UIKit
import DropDown

protocol filtersSelectedDelegate: class {
    func filtersSelected(forFilterCategory: String, forFilterRating: Double, forFilterDistance:Double?)
}

class FilterViewController: UIViewController {
    deinit {
        print("destroying filtervc")
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var applyButton: UIBarButtonItem!
    
    let dropDown = DropDown()
    
    var filterCategory:String = "All"
    var filterRating:Double = 5
    var filterDistance:Double?
    
    var categoryCell:UITableViewCell?
    var ratingCell:RatingFilterCell?
    var distanceCell:distanceFilterCell?

    weak var delegate:filtersSelectedDelegate?

    var filterCategories = ["All"]
    
    func enableButtons(){
        clearButton.isEnabled = true
        applyButton.isEnabled = true
    }
    
    func disableButtons(){
        clearButton.isEnabled = false
        applyButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if let cell = categoryCell{
                cell.textLabel?.text = item
                dropDown.selectRow(at: index)
                filterCategory = item
                self.enableButtons()
            }
        }
    }
    
    @IBAction func clearFilters(_ sender: Any) {
//        filterCategory = nil
//        filterRating = nil
        filterDistance = nil
        
        categoryCell?.textLabel?.text = "All"
        ratingCell?.resetStars()
        distanceCell?.resetDistance()
        
        disableButtons()
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        delegate?.filtersSelected(forFilterCategory: filterCategory, forFilterRating: filterRating, forFilterDistance: filterDistance)
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension FilterViewController: ratingSelectedDelegate, distanceSelectedDelegate{
    
    func distanceSelected(forDistance: Double) {
        filterDistance = forDistance
        self.enableButtons()
        print("for distance selected \(forDistance)")
    }
    
    
    func ratingSelected(forRating: Double) {
        filterRating = forRating
        self.enableButtons()
        print("for rating selected \(forRating)")
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "BY CATEGORY"
        }
        else if section == 1{
            return "BY RATING AND ABOVE"
        }
        else {
            return "WITHIN DISTANCE"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            categoryCell = cell
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "All"
            return cell
        }
        else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RatingFilterCell", for: indexPath) as! RatingFilterCell
            ratingCell = cell
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "distanceFilterCell", for: indexPath) as! distanceFilterCell
            distanceCell = cell
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            dropDown.dataSource = filterCategories
            let cell = tableView.cellForRow(at: indexPath)
            categoryCell = cell!
            dropDown.anchorView = cell?.contentView
            dropDown.selectRow(at: 0)
            dropDown.show()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

