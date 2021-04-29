//
//  String+AppendStrings.swift
//  iOSProj
//
//  Created by Jackson Lu on 4/28/21.
//

import Foundation

extension String{
    mutating func displayAddress(address: [String], separatedBy separator: String) {
        if !address.isEmpty{
            for line in address{
                self = self + line + separator
            }
        }
    }
}
