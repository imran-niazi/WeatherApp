//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Imran Niazi on 3/4/17.
//  Copyright © 2017 Imran Niazi. All rights reserved.
//

import UIKit
import RxSwift  //Reactive Swift allows to do Function Reactive Programming style
import Bond //This framework helps in observing and binding

//  Below class has been implemented as Weather View Model and will be responsible for providing weather data to the controller
 public class WeatherViewModel
{
    //Following variables will be observed by ViewController in order to display change to UI
    public var locationName = Observable("Location")
    public var weatherDescription = Observable("Weather Description")
    public var currentTemp = Observable("--")
    public var humidity = Observable("0.0%")
    public var iconImage = Observable(UIImage())
    public var tempMax = Observable("__")
    public var tempMin = Observable("__")
    public var windSpeed = Observable("0.0 m/s")
    public var errorDescription = Observable("")
    
    public init(){}
    /**
     Send request for weather information by city and set properties from data model in case of success
     
     @param locationParm takes city name string
    
     */
    public func searchWeatherForLocation(locationParm: String)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkManager.sharedInstance.requestWeatherInfo(withLocation: locationParm, completion: { [unowned self] (weatherData, errorString) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard errorString == nil else {
                //Error Handling
                self.errorDescription.value = errorString ?? "Error not specified"
                return
            }
            self.setWeatherInfo(weatherParm: weatherData)
            
        })
    }
    
    /**
     Send request for weather information by last city search and set properties from data model in case of success
     */
    public func displayLastSearch()
    {
        if let lastSearch = UserDefaults.standard.value(forKey: "lastSearchKeyword") as? String
        {
            NetworkManager.sharedInstance.requestWeatherInfo(withLocation: lastSearch, completion: { [unowned self] (weatherData, errorString) in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                guard errorString == nil else {
                    //Error Handling
                    self.errorDescription.value = errorString ?? "Error not specified"
                    return
                }
                self.setWeatherInfo(weatherParm: weatherData)
            })
        }
        else
        {
            print("Enter location for weather")
        }
    }
    
    /**
     Set properties from data model
     */
    private func setWeatherInfo(weatherParm: WeatherData?)
    {
        guard weatherParm != nil else {return}
    
        self.errorDescription.value = ""
        if let wSearchLocation = weatherParm?.location
        {
            self.locationName.value = wSearchLocation
            UserDefaults.standard.setValue(wSearchLocation, forKey: "lastSearchKeyword")
        }
        
        if let wDescription = weatherParm?.weatherDescription
        {
            self.weatherDescription.value = wDescription
        }
        
        if let wCurrentTemp = weatherParm?.currentTemp
        {
            self.currentTemp.value = convertToFahrenheitString(kelvinTemp: wCurrentTemp)
        }
        
        if let wHumidity = weatherParm?.humidity
        {
            self.humidity.value = "\(wHumidity) %"
        }
        
        if let wTempMax = weatherParm?.tempMax
        {
            self.tempMax.value = convertToFahrenheitString(kelvinTemp:wTempMax)
        }

        if let wTempMin = weatherParm?.tempMin
        {
            self.tempMin.value = convertToFahrenheitString(kelvinTemp:wTempMin)
        }
        
        if let wSpeed = weatherParm?.windSpeed
        {
            self.windSpeed.value = "\(wSpeed) m/s"
        }
        
        //call for weather icon image
        if let icName = weatherParm?.iconName
        {
            NetworkManager.sharedInstance.downloadWeatherIcon(withName: icName){ [unowned self] (data, errorString) in
                
                guard errorString == nil, let data = data else {
                    //Error Handling
                    self.errorDescription.value = errorString ?? "Error not specified"
                    return
                }
                
                if let icImage = UIImage(data: data)
                {
                    self.iconImage.value = icImage
                }
            }
        }
    }
    
    /**
     Convert Kelvin to Fahrenheit.
     
     @param kelvinTemp, the temperature in kelvin to convert
     
     @return Fahrenheit value in string.
     */
    private func convertToFahrenheitString(kelvinTemp: Double)->(String)
    {
        guard kelvinTemp >= 0.0 else { return "0.0°" }
        return "\(Int(((kelvinTemp * 1.8)-459.67)))°"
    }
}
