//
//  yelpStars.swift
//  iOSProj
//
//  Created by Jackson Lu on 4/27/21.
//

import Foundation
import UIKit

struct Reviews {
    
    static let dict = [
        0: Reviews.zero,
        1: Reviews.one,
        1.5: Reviews.oneHalf,
        2: Reviews.two,
        2.5: Reviews.twoHalf,
        3: Reviews.three,
        3.5: Reviews.threeHalf,
        4: Reviews.four,
        4.5: Reviews.fourHalf,
        5: Reviews.five
    ]
    
    
    static let zero = UIImage(named: "regular_0")
    static let one = UIImage(named: "regular_1")
    static let oneHalf = UIImage(named: "regular_1_half")
    static let two = UIImage(named: "regular_2")
    static let twoHalf = UIImage(named: "regular_2_half")
    static let three = UIImage(named: "regular_3")
    static let threeHalf = UIImage(named: "regular_3_half")
    static let four = UIImage(named: "regular_4")
    static let fourHalf = UIImage(named: "regular_4_half")
    static let five = UIImage(named: "regular_5")
    
        
}
