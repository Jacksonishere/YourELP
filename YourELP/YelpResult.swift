//
//  YelpResult.swift
//  iOSProj
//
//  Created by Jackson Lu on 4/21/21.
//

import Foundation
import MapKit


class YelpResultArray:Codable{
    var businesses:[Business]
//    var total:Int
    var region:Region
}

class Business:Codable{
    var id:String
    var name:String
    var image_url:String
    var rating:Double
    var categories:[Category]
    var coordinates:LocationCoordinate
    var price:String?
    var location:address
    var display_phone:String
}

class Category:Codable{
    var alias:String
    var title:String
}

class LocationCoordinate: NSObject, Codable, MKAnnotation {
    var coordinate: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var latitude:Double
    var longitude:Double
}

class address: Codable{
    var display_address:[String]
}

class Region: Codable{
    var center:LocationCoordinate
}
