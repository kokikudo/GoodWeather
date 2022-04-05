//
//  WeatherResult.swift
//  GoodWeather
//
//  Created by Mohammad Azam on 3/7/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation

struct WeatherResult: Decodable {
    let main: Weather
}

extension WeatherResult {
    
    static var empty: WeatherResult {
        return WeatherResult(main: Weather(temp: 0.0, humidity: 0.0))
    }
    
}

struct Weather: Decodable {
    let temp: Double
    let humidity: Double
}
