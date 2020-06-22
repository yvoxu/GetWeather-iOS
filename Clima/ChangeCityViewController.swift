//
//  ChangeCityViewController.swift
//  WeatherApp


import UIKit

//Write the protocol declaration here:
protocol ChangeCityDelegate {
    func newCityNameEntered(city : String)
}


class ChangeCityViewController: UIViewController {
    
    var delegate : ChangeCityDelegate? //optional
    
    //This is the pre-linked IBOutlets to the text field:
    @IBOutlet weak var changeCityTextField: UITextField!

    
    //This is the IBAction that gets called when the user taps on the "Get Weather" button:
    @IBAction func getWeatherPressed(_ sender: AnyObject) {

        //1 Get the city name the user entered in the text field
        let cityName = changeCityTextField.text!
        
        //2 If the delegate contains a value, call the method newCityNameEntered
        delegate?.newCityNameEntered(city: cityName) //delegate is already set to WeatherViewController
        
        //3 dismiss the Change City View Controller to go back to the WeatherViewController
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
