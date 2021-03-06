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
import CoreLocation

class NetworkingManager {
    //Probably overkill since I only have one class depending on this but it just felt wrong to have a class like this that wasn't a singleton.
    static let sharedInstance : NetworkingManager = {
        let instance = NetworkingManager()
        return instance
    }()
    
    var weatherDelegate: WeatherDataSource?
    var lat: CGFloat = 0.0
    var long: CGFloat = 0.0
    // Get nearby currentWeather with current forecasts of varying kinds
    //
    // Typically I would make these class functions but doing a Singleton pattern 
    // with internal methods was easier since I'm using Timer and it was having issues
    func beginPollingCurrentWeather() {
        guard let _ = weatherDelegate else { return }
        
        self.getCurrentWeather()
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.getCurrentWeather), userInfo: nil, repeats: true);
    }
    
    @objc func getCurrentWeather() {
        guard let weatherDelegate = weatherDelegate else {
            print("Quitting - no valid delegate was found for weather info")
            return
        }
        
        if (lat == 0 && long == 0) {
            return
        }
        
        let queue = DispatchQueue(label: "com.nlambson.weather-queue", qos: .utility, attributes: [.concurrent])
        Alamofire.request("https://api.darksky.net/forecast/97e181598dfdda956b83cf03bf82b1d2/\(lat),\(long)").responseJSON(
            queue: queue,
            completionHandler: { response in
                if let JSON = response.result.value {
                    do {
                        let snapshot = try WeatherSnapshot(object: JSON as! MarshaledObject)
                        let locationForSnapshot = CLLocation(latitude: CLLocationDegrees(snapshot.latitude), longitude: CLLocationDegrees(snapshot.longitude))
                        
                        CLGeocoder().reverseGeocodeLocation(locationForSnapshot, completionHandler: {(placemarks, error) -> Void in
                            if (error != nil) {
                                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                                return
                            }
                            
                            if let pm = placemarks?[0] {
                                snapshot.locationText = "\(pm.locality!), \(pm.administrativeArea!)"
                            } else {
                                print("Problem with the data received from geocoder")
                            }
                        })
                        
                        let futureSnapshots: [MinuteForecast] = try (JSON as! MarshaledObject).value(for: "minutely.data")
                        
                        DispatchQueue.main.async {
                            weatherDelegate.next(current: snapshot, minutely: futureSnapshots)
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
