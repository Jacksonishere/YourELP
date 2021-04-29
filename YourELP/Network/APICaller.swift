//
//  APICaller.swift
//  iOSProj
//
//  Created by Jackson Lu on 4/27/21.
//

import Foundation

private var apiKey = "uVq481uD0mBvTkk3v4H62JOEr6_IMu_A0gSff2Fe_3xZf9u5z2aomsyqhmexTnci2L7zAOh747X55q-FPQ29zEg3mre-WVF5s1_pGi_w2m6saDxfQwKmUcHFBp5_YHYx"

struct APICaller{
    
    
    static func getBusinesses(with url:URL, completion: @escaping ([Business]) -> Void){
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        dataTask = session.dataTask(with: request) {data, response, error in

            if let error = error as NSError?, error.code == -999 {
                return
            }
        
    }
}
