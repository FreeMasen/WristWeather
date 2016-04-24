//
//  ViewController.swift
//  WristWeather
//
//  Created by Robert Masen on 3/30/16.
//  Copyright © 2016 Robert Masen. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var weather: Weather?
    var lm = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        lm.delegate = self
        lm.requestAlwaysAuthorization()
        lm.desiredAccuracy = kCLLocationAccuracyHundredMeters
        lm.requestLocation()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        Location.lat = newLocation.coordinate.longitude
        Location.long = newLocation.coordinate.longitude
        
        ForecastHelper.getWeather { weather in
            self.weather = weather
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: ViewController.didfailwitherror: \(error)")
        print("currentAuth: \(CLLocationManager.authorizationStatus())")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Location.lat = locations[0].coordinate.latitude
        Location.long = locations[0].coordinate.longitude
        
        ForecastHelper.getWeather { weather in
            self.weather = weather
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lm.requestLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

