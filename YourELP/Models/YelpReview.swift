//
//  YelpReview.swift
//  YourELP
//
//  Created by Jackson Lu on 4/29/21.
//

import Foundation

struct YelpReviewArray:Codable{
    var reviews:[review]
}

struct review:Codable{
    var text:String
    var rating:Double
    var time_created:String
    var user:User
}

struct User:Codable {
    var image_url:String?
    var name:String
}
