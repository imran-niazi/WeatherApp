//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Imran Niazi on 3/2/17.
//  Copyright © 2017 Imran Niazi. All rights reserved.
//

import UIKit
import RxCocoa //This framework will help us observing Search Bar text
import RxSwift //This framework will help dispose and debounce main scheduler for search bar
import Weather //This weather framework that will do all data processing

//  Below controller will be responsible connecting UI to weather view model and receive any user events
class WeatherViewController: UIViewController
{
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var errorLabel: UILabel!
    
    let disposeBag = DisposeBag()   //To dispose all subscribed events once over
    let weatherVm = WeatherViewModel() //Instance of Weather View Model that will be responsible for all the data
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.weatherVm.displayLastSearch()
        //Observe search bar text
        searchBar
            .rx.text // Observable property thanks to RxCocoa
            .orEmpty // Make it non-optional
            .debounce(2.0, scheduler: MainScheduler.instance) // Wait 2.0 for changes.
            .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
            .filter { !$0.isEmpty } // If the new value is really new, filter for non-empty query.
            .subscribe(onNext: { [unowned self] query in // Here we will be notified of every new value
                print("\(query)")
                self.searchBar.resignFirstResponder()
                self.weatherVm.searchWeatherForLocation(locationParm: query)
                })
            .addDisposableTo(disposeBag)
        
        //UI Binding
        self.weatherVm.locationName.bind(to: locationLabel)
        self.weatherVm.weatherDescription.bind(to: weatherDescriptionLabel)
        self.weatherVm.currentTemp.bind(to: currentTempLabel)
        self.weatherVm.humidity.bind(to: humidityLabel)
        self.weatherVm.tempMax.bind(to: tempMaxLabel)
        self.weatherVm.tempMin.bind(to: tempMinLabel)
        self.weatherVm.windSpeed.bind(to: windSpeedLabel)
        self.weatherVm.iconImage.bind(to: weatherIconImageView)
        self.weatherVm.errorDescription.bind(to: errorLabel)
    }
}
