//
//  MinuteForecast.swift
//  Weather
//
//  Created by Nathan Lambson on 11/27/16.
//  Copyright © 2016 Nathan Lambson. All rights reserved.
//

import Foundation
import Marshal

struct MinuteForecast: Unmarshaling {
    
    var time: Int
    var precipProbability: Int
    
    init(object: MarshaledObject) throws {
        time = try object.value(for: "time")
        precipProbability = try object.value(for: "precipProbability")
    }
}
