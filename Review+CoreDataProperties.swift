//
//  Review+CoreDataProperties.swift
//  YourELP
//
//  Created by Jackson Lu on 4/30/21.
//
//

import Foundation
import CoreData


extension Review {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Review> {
        return NSFetchRequest<Review>(entityName: "Review")
    }

    @NSManaged public var photoURLS: [String]?
    @NSManaged public var businessAddress: [String]
    @NSManaged public var rating: Double
    @NSManaged public var businessName: String
    @NSManaged public var businessID: String
    @NSManaged public var category: String
    @NSManaged public var reviewDesc: String

}

extension Review : Identifiable {

}
