//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "dd49d1f6b73913a3c2da257a135d9662"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    //Objects
    var weatherDataModel : WeatherDataModel = WeatherDataModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherDara(url : String,params : [String : String]) -> Void {
    
        Alamofire.request(url, method: .get, parameters: params).responseJSON {
            response in
            if(response.result.isSuccess){
                print("Success... Got weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(response: weatherJSON)
            }else{
                print("Error is: \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(response : JSON) -> Void {
        if response != JSON.null {
        weatherDataModel.temperature = Int(response["main"]["temp"].double! - 273.15)
        weatherDataModel.city = String(describing: response["name"])
        weatherDataModel.weatherCondition = Int(response["weather"][0]["id"].intValue)
        weatherDataModel.iconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.weatherCondition)
            
            updateUI()
            
        }else{
            cityLabel.text = "Weather Unavailable"
        }
    }
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUI() -> Void {
        cityLabel.text = String(weatherDataModel.city)
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.iconName)
    }
    
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if(location.horizontalAccuracy > 0){
            locationManager.stopUpdatingLocation()
            print("Longitude: \(location.coordinate.longitude), Latitude: \(location.coordinate.latitude)")
            let longitude = location.coordinate.longitude
            let latitude = location.coordinate.latitude
            let params : [String: String] = ["lat": String(latitude), "lon" : String(longitude), "appid" : APP_ID]
            
            //Getting the weather data
            
            getWeatherDara(url: WEATHER_URL, params: params)
        }
    }
    
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredNewCityName(city: String) {
        let params : [String : String] = ["q" : String(city),"appid" : APP_ID]
        getWeatherDara(url: WEATHER_URL, params: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
    
}


