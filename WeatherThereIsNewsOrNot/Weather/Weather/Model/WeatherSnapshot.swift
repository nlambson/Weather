//
//  WeatherSnapshot.swift
//  Weather
//
//  Created by Nathan Lambson on 11/26/16.
//  Copyright © 2016 Nathan Lambson. All rights reserved.
//

import Foundation
import Marshal

protocol WeatherDataSource {
    func next(current: WeatherSnapshot, minutely: [MinuteForecast])
}

class WeatherSnapshot: Unmarshaling {
    var timezone: String
    var offset: Int
    var locationText: String?
    
    var latitude: Float
    var longitude: Float
    var time: Int
    var summary: String
    var precipProbability: Float
    var temperature: Float
    var humidity: Float
    var windSpeed: Float
    var cloudCover: Float
    
    required init(object: MarshaledObject) throws {
        timezone = try object.value(for: "timezone")
        offset = try object.value(for: "offset")
        latitude = try object.value(for: "latitude")
        longitude = try object.value(for: "longitude")
        
        time = try object.value(for: "currently.time")
        summary = try object.value(for: "currently.summary")
        
        precipProbability = try object.value(for: "currently.precipProbability")
        temperature = try object.value(for: "currently.temperature")
        humidity = try object.value(for: "currently.humidity")
        windSpeed = try object.value(for: "currently.windSpeed")
        cloudCover = try object.value(for: "currently.cloudCover")
    }
}
