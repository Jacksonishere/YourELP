//
//  imageCache.swift
//  YourELP
//
//  Created by Jackson Lu on 5/6/21.
//

import Foundation
import UIKit

class imageCache{
    var imageDict:[String:UIImage]
    
//    private static var _current:imageCache?
//
//    static var current: imageCache {
//        guard let currentCache = _current else {
//            fatalError("Error: current user doesn't exist")
//        }
//
//        return currentCache
//    }
    static let current = imageCache()

    private init() {
        imageDict = [String:UIImage]()
        let fileManager = FileManager.default
        let documentsURL = applicationDocumentsDirectory
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for file in fileURLs{
                let filename = file.path.components(separatedBy: "/").last
                if let image = UIImage(contentsOfFile: file.path){
                    imageDict[filename!] = image
                }
            }
        }
        catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
}
