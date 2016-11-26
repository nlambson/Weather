//
//  WeatherSnapshot.swift
//  Weather
//
//  Created by Nathan Lambson on 11/26/16.
//  Copyright © 2016 Nathan Lambson. All rights reserved.
//

import Foundation
import Marshal

struct WeatherSnapshot: Unmarshaling {
    var timezone: String
    var offset: Int
    
    var time: Int
    var summary: String
    var precipProbability: Int
    var temperature: Float
    var humidity: Float
    
    init(object: MarshaledObject) throws {
        timezone = try object.value(for: "timezone")
        offset = try object.value(for: "offset")
        
        time = try object.value(for: "currently.time")
        summary = try object.value(for: "currently.summary")
        precipProbability = try object.value(for: "currently.precipProbability")
        temperature = try object.value(for: "currently.temperature")
        humidity = try object.value(for: "currently.humidity")
    }
}
