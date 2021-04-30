//
//  Review+CoreDataProperties.swift
//  
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

    @NSManaged public var restName: String?
    @NSManaged public var rating: Double
    @NSManaged public var reviewDesc: String?
    @NSManaged public var photoIDs: [NSNumber]?

}
