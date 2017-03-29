//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Imran Niazi on 3/2/17.
//  Copyright © 2017 Imran Niazi. All rights reserved.
//

//  Below class has been implemented using the 'Singleton Pattern' in order to make service request and optimize
//  memory allocation by having one global instance.

import Foundation

class NetworkManager
{
    static let sharedInstance = NetworkManager()    //Create global singleton instance
    
    /**
     Send request for weather information by city.
     
     @param withLocation takes city name string
     
     @return Completion handler with data model weather data if successful otherwise send error string.
     */
    func requestWeatherInfo(withLocation: String, completion: @escaping (WeatherData?, _ errorString: String?)->())
    {
        let urlString = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(withLocation)&appid=010ddc9e1e96d8160253174a54e953fc")
        
        guard urlString != nil else{
            //Error
            completion(nil, "Incorrect Url")
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlString!) { (data, response, error) in
            if error != nil
            {
                completion(nil, error?.localizedDescription)
            }
            else
            {
                guard data != nil else { return }
                do
                {
                    let anyObj = try JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
                    print(anyObj)
                    
                    if let message = anyObj["message"] as? String
                    {
                        completion(nil, message)
                    }
                    else
                    {   //Success
                        let weatherData = WeatherData(fromDictionary: anyObj)
                        completion(weatherData, nil)
                    }
                }
                catch
                {
                    //Error
                    print("json error: \(error.localizedDescription)")
                    completion(nil, error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    /**
     Download weather icons with icon name.
     
     @param withName takes icon name like "09d" as string
     
     @return Completion handler with image data if successful otherwise send error string.
     */
    func downloadWeatherIcon(withName: String, completion: @escaping (Data?, _ errorString: String?) -> ())
    {
        let urlString = URL(string: "http://openweathermap.org/img/w/\(withName).png")
        
        guard urlString != nil else{
            //Need Error Display
            completion(nil, "Incorrect Url")
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlString!) { (data, response, error) in
            
            if let imageData = data
            {
                completion(imageData, nil)
            }
            else
            {
                print("Error download data:\(error?.localizedDescription)")
                completion(nil, error?.localizedDescription)
            }
        }
        task.resume()
    }
}

