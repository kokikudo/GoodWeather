//
//  URL+Extensions.swift
//  GoodWeather
//
//  Created by Mohammad Azam on 3/9/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation

extension URL {
    
    static func urlForWeatherAPI(city: String) -> URL? {
        return URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&APPID=f9e51e2a1c21397616df28d563c4420b&units=imperial")
    }
    
}
