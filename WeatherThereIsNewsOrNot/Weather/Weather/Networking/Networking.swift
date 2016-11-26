//
//  Networking.swift
//  Weather
//
//  Created by Nathan Lambson on 11/26/16.
//  Copyright © 2016 Nathan Lambson. All rights reserved.
//

import Foundation
import Marshal
//https://api.darksky.net/forecast/97e181598dfdda956b83cf03bf82b1d2/37.8267,-122.4233

import Foundation
import Alamofire

class Networking {
    
    // Get nearby events by a provided Zip Code
    class func getCurrentWeather() {
        
        Alamofire.request("https://api.darksky.net/forecast/97e181598dfdda956b83cf03bf82b1d2/37.8267,-122.4233").responseJSON { response in

            if let JSON = response.result.value {
                do {
                    let snapShot = try WeatherSnapshot(object: JSON as! MarshaledObject)
                    
                    print("snapShot: \(snapShot)")
                }
                catch _ {
                    print("failed hard")
                }
            }
            

        }
        
    }
}
