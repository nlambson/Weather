//
//  Networking.swift
//  Weather
//
//  Created by Nathan Lambson on 11/26/16.
//  Copyright © 2016 Nathan Lambson. All rights reserved.
//

import Foundation
import Marshal

import Foundation
import Alamofire

class NetworkingManager {
    //Not necessary since I only have one class but it just felt wrong to have a class like this that wasn't a singleton.
    static let sharedInstance : NetworkingManager = {
        let instance = NetworkingManager()
        return instance
    }()
    
    var weatherDelegate: WeatherSnapshotDataSource?
    
    // Get nearby currentWeather with current forecasts of varying kinds
    //
    // Typically I would make these class functions but doing a Singleton pattern 
    // with internal methods was easier since I'm using Timer and it was having issues
    func beginPollingCurrentWeather() {
        guard let _ = weatherDelegate else { return }
        
        //The Dark Sky API has a 60 second resolution
        self.getCurrentWeather()
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getCurrentWeather), userInfo: nil, repeats: true);
    }
    
    @objc func getCurrentWeather() {
        guard let weatherDelegate = weatherDelegate else {
            print("Quitting - no valid delegate was found for weather info")
            return
        }
        
        let queue = DispatchQueue(label: "com.nlambson.weather-queue", qos: .utility, attributes: [.concurrent])
        
        Alamofire.request("https://api.darksky.net/forecast/97e181598dfdda956b83cf03bf82b1d2/37.8267,-122.4233").responseJSON(
            queue: queue,
            completionHandler: { response in
                if let JSON = response.result.value {
                    do {
                        let snapShot = try WeatherSnapshot(object: JSON as! MarshaledObject)
                        
                        DispatchQueue.main.async {
                            weatherDelegate.next(latest: snapShot)
                        }
                    }
                    catch _ {
                        print("failed hard")
                    }
                }
                
                
        }
        )
    }
}
