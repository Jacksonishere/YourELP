//
//  String+AppendStrings.swift
//  iOSProj
//
//  Created by Jackson Lu on 4/28/21.
//

import Foundation
import CoreLocation

extension String{
    mutating func displayAddress(address: [String], separatedBy separator: String) {
        if !address.isEmpty{
            let numLines = address.count
            for i in 0..<numLines{
                if i + 1 == numLines{
                    self = self + address[i]
                }
                else{
                    self = self + address[i] + separator
                }
            }
        }
    }
    
    mutating func getTimeStamp(fixTimestamp: String){
        var dateSplit = self.components(separatedBy: "-")
        dateSplit[2].removeLast(dateSplit[2].count - 2)
        self = dateSplit[1] + "/" + dateSplit[2] + "/" + dateSplit[0]
    }
    
    init(forPlacemark placemark: CLPlacemark) {
        var initStr = "Current Address:\n"
        let streetInfo = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
        ].compactMap{$0}.joined(separator: " ")
        
    
        initStr.append(streetInfo)
        initStr += "\n"
        
        let cityInfo = [
            placemark.subLocality,
            placemark.locality,
        ].compactMap{$0}.joined(separator: " ")
        
        print("city info \(cityInfo)")
        if cityInfo != ""{
            initStr.append(cityInfo)
            initStr += "\n"
        }
        
        let zipInfo = [
            placemark.postalCode
        ].compactMap{$0}.joined(separator: " ")
        
        print("zip info \(zipInfo)")
        initStr.append(zipInfo)
        
//        print(initStr)
        self.init(initStr)
    }
}
