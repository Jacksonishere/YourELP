//
//  Review+CoreDataClass.swift
//  YourELP
//
//  Created by Jackson Lu on 4/30/21.
//
//

import Foundation
import CoreData

@objc(Review)
public class Review: NSManagedObject {
//    var hasPhotos: Bool {
//        return photoURLS != nil
//    }
//    
    var numPhotos: Int {
        if photoURLS != nil{
            print(photoURLS!.count, "num photos")
            return photoURLS!.count
        }
        else{
            return 0
        }
    }
    func removePhotoFiles(numtoRv numRv:Int) {
        for i in 0 ..< numRv{
            do {
                let photoURL = photoURLS![numPhotos - i - 1]
                try FileManager.default.removeItem(at: applicationDocumentsDirectory.appendingPathComponent(photoURL))
                imageCache.current.imageDict[photoURL] = nil
            }
            catch {
                print("Error removing file: \(error)")
            }
        }
    }
    
    class func nextPhotoIDBeginning(numPhotos:Int) -> Int {
      let userDefaults = UserDefaults.standard
      let currentID = userDefaults.integer(forKey: "PhotoIDBeginning") 
      userDefaults.set(currentID + numPhotos, forKey: "PhotoIDBeginning")
      return currentID
    }
}
