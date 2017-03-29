//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Imran Niazi on 3/2/17.
//  Copyright © 2017 Imran Niazi. All rights reserved.
//

import UIKit

class WeatherData
{
    var location: String?
    var weatherDescription: String?
    var currentTemp: Double?
    var iconName: String?
    var humidity: Double?
    var tempMax: Double?
    var tempMin: Double?
    var windSpeed: Double?
    
    init(fromDictionary: [String: AnyObject])
    {
        self.location = fromDictionary["name"] as? String
        if let main = fromDictionary["main"] as? [String : AnyObject]
        {
            self.currentTemp = main["temp"] as? Double
            self.tempMax = main["temp_max"] as? Double
            self.tempMin = main["temp_min"] as? Double
            self.humidity = main["humidity"] as? Double
        }
        
        if let wind = fromDictionary["wind"] as? [String : AnyObject]
        {
            self.windSpeed = wind["speed"] as? Double
        }
                
        if let weather = fromDictionary["weather"] as? [[String : AnyObject]]
        {
            self.weatherDescription = weather[0]["description"] as? String
            self.iconName = weather[0]["icon"] as? String
        }
    }
}
