//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Giulia Ariu on 09/12/2018.
//  Copyright © 2018 Giulia Ariu. All rights reserved.
//


import UIKit

protocol ChangeCityDelegate {
    
    //This method will be implemented in the delegate class
    func userEnteredANewCityName (city : String)
}


class ChangeCityViewController: UIViewController {
    
    var delegate : ChangeCityDelegate?
    
    @IBOutlet weak var changeCityTextField: UITextField!

    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredANewCityName(city: cityName)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
