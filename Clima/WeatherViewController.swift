//
//  ViewController.swift
//  WeatherApp
//
//  Created by Giulia Ariu on 10/12/2018.
//  Copyright © 2018 Giulia Ariu. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //CONSTANTS
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    
    ///INSERT API KEY HERE
    let APP_ID = ""
    

    //Instance variables
    
    let locationManager = CLLocationManager()
    
    let weatherDataModel = WeatherDataModel()

    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var celsiusToFahrenheitSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //In order to use the location manager this class has to become a delegate of the location manager
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        
        locationManager.requestWhenInUseAuthorization()
        
        //Starts the process when the location manager starts looking for gps coordinates of current iPhone
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /**************************************************************/
    
    //Method activated once the locationManager has the location
    //Location is saved in an array of CoreLocation Objects, the last value in this array will be the most accurate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            
            //As soon as the location manager gets a valid result it stops updating the location
            locationManager.stopUpdatingLocation()
            
            //This stop this view controller from receiving messages from the location manager
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            //Parameters needed to retrieve data by http request
            let params : [String : String]  = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url : WEATHER_URL, parameters : params)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    func getWeatherData(url: String, parameters: [String : String])
    {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON
        {
            response in
            if response.result.isSuccess
            {
                print("Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                //We need self because it tells the compiler to look for this function inside the current class
                self.updateWeatherData(json: weatherJSON)
            }
            else
            {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    

    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    func updateWeatherData(json : JSON)
    {
        
        //It searches the key main and then inside it it searches the key temp
        if let tempResult = json["main"]["temp"].double
        {
            //Conversion from Kelvin to Celsius
            weatherDataModel.temperature = Int(tempResult - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            print(weatherDataModel.condition)
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        else
        {
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    func updateUIWithWeatherData()
    {
        cityLabel.text = "🌍 \(weatherDataModel.city)"

        celsiusFahrenheitConversion(weatherDataModel.temperature)
        
//        temperatureLabel.text = String(weatherDataModel.temperature) + " °C"
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    fileprivate func celsiusFahrenheitConversion(_ celsiusTemp: Int) {
        if celsiusToFahrenheitSwitch.isOn
        {
            temperatureLabel.text = String(celsiusTemp) + " °C"
        }
        else
        {
            temperatureLabel.text = String ( (Double(celsiusTemp) * 1.8 + 32) ) + " °F"
        }
    }
    
    @IBAction func celsiusToFahrenheit(_ sender: Any) {
        
        let celsiusTemp = weatherDataModel.temperature
        
        celsiusFahrenheitConversion(celsiusTemp)
    }
    
    

    
    //MARK: - Change City Delegate methods
    /**************************************************************/
    
    
    func userEnteredANewCityName(city: String) {
        
        //Dictionary that contains the parameters that will be sent to openWeatherMap as written in openWeatherMap instructions
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    
    //Change of view controller from WeatherViewController to ChangeCityViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName"
        {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            //This class is now the ChangeCityViewController delegate
            destinationVC.delegate = self
        }
    }
    
    
    
}


