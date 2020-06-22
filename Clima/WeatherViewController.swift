//
//  ViewController.swift
//  WeatherApp


import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "524e54cc7100dae7d2c7fcb25b99d6c3"
    

    //Declare instance variables
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Set up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters //better accuracy, more time cost, more battery usage
        locationManager.requestWhenInUseAuthorization() //trigger authrization pop-up (need to add a description to plist for pop-up to appear)
        locationManager.startUpdatingLocation() //run in the background
        
    }
    

    //Networking
    /***************************************************************/
    func getWeatherData(url : String, parameters: [String : String]) {
        
        AF.request(url, method: .get, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success:
                let weatherJSON : JSON = JSON(response.value!)
                self.updateWeatherData(json: weatherJSON)
            case .failure(let error):
                print(error.localizedDescription)
                self.cityLabel.text = "Connection Issues"
            }
        }
    }


    //JSON Parsing
    /***************************************************************/
    func updateWeatherData(json : JSON){
        
        if let temp = json["main"]["temp"].double{
            
            weatherDataModel.temperature = Int(temp - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }else{
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    //UI Updates
    /***************************************************************/
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature) + "°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    

    //Location Manager Delegate Methods
    /***************************************************************/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1] //get the last (most accurate/recent) location from the array
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longtitude = String(location.coordinate.longitude)
            
            let coordinates : [String : String] = ["lat" : latitude, "lon" : longtitude, "appid" : APP_ID]
        
            getWeatherData(url : WEATHER_URL, parameters: coordinates)
        }
    }
    
    
    //didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    //Change City Delegate methods
    /***************************************************************/
    func newCityNameEntered(city : String){
        let params : [String : String] = ["q" : city, "appid" : APP_ID] //according to OpenWeather API, use "q" as the key to get weather by city name
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController //a new copy of ChangeCityViewController) is created after seague
            destinationVC.delegate = self //set WeatherViewController as the delegate of ChangeCityViewController to receive city name sent from ChangeCityViewController
        }
    }
    
    
    
    
}


