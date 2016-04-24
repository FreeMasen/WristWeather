//
//  InterfaceController.swift
//  WristWeather WatchKit Extension
//
//  Created by Robert Masen on 3/30/16.
//  Copyright © 2016 Robert Masen. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    @IBOutlet var currentTemp: WKInterfaceLabel!
    @IBOutlet var currentSummary: WKInterfaceLabel!
    @IBOutlet var todaysHigh: WKInterfaceLabel!
    @IBOutlet var todaysLow: WKInterfaceLabel!
    @IBOutlet var viewFull: WKInterfaceButton!
    @IBOutlet var location: WKInterfaceLabel!
    @IBOutlet var spinner: WKInterfaceImage!

    var lm = CLLocationManager()
    
    var currentLocation: CLLocation? {
        didSet {
            if let currentLocation = currentLocation {
                Location.updateLocation(currentLocation) { place in
                    self.location.setText(place)
                    ForecastHelper.getWeather { weather in
                        self.weather = weather
                    }
                }

            }
        }
    }
    
    var weather: Weather? {
        didSet {
            if let weather = weather {
                currentTemp.setText("\(weather.CurrentTemp)°F")
                currentSummary.setText(weather.CurrentSummary)
                todaysHigh.setText("\(weather.HighTemp[0])°F")
                todaysLow.setText("\(weather.LowTemp[0])°F")
                stopSpinning()
                viewFull.setHidden(false)
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        lm.delegate = self
        lm.requestAlwaysAuthorization()
        lm.desiredAccuracy = kCLLocationAccuracyHundredMeters
        lm.requestLocation()
        spin()
    }
    
    @IBAction func seeDays() {
        let context = ["day":1,"weather":self.weather!]
        presentControllerWithName("DayForecast", context: context)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        currentLocation = newLocation
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: InterfaceController.didFailWithError: \(error)")
        print("Current Auth: \(CLLocationManager.authorizationStatus().rawValue)")
        lm.requestLocation()
    }
    func spin() {
        spinner.setHidden(false)
        let duration = 1.2
        spinner.setImageNamed("Progress")
        spinner.startAnimatingWithImagesInRange(NSRange(location: 0, length: 20), duration: duration, repeatCount: 100)
    }
    func stopSpinning() {
        spinner.setHidden(true)
        spinner.stopAnimating()
    }
}
