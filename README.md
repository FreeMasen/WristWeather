WristWeather
===============
Class project for iOS

User Experience
----------------------
#### Basic Use
Once the application is launched, it attempts to get the weather for the location of the user
TODO: insert loading image
once this has completed it will display a current weather information
TODO: insert weather image
by touching the button at the bottom of the screen you will see the detailed view of
the upcoming weather.

by touching the arrows you can navigate though (typically) 8 days of weather information
the x button will get you back to the main screen

Code
-----------
The application utilizes one simple object to keep track of weather.
This object has the following properties
``` swift
import Foundation

class Weather {
    
    var CurrentTemp: Double
    var CurrentSummary: String
    var PrecipChance: Double
    var WindSpeed: Double
    var HighTemp: [Double]
    var LowTemp: [Double]
    var DaySummary: [String]
  ```
  this can be constructed in two methods, first is a literal approach
  the second is an interpretation of JSON returned by our data source
  ``` swift
    init(currentTemp: Double, currentSummary: String, precipChance: Double, windSpeed: Double, highTemp: [Double], lowTemp: [Double], daySummary: [String]) {
        CurrentTemp = currentTemp
        CurrentSummary = currentSummary
        PrecipChance = precipChance
        WindSpeed = windSpeed
        HighTemp = highTemp
        LowTemp = lowTemp
        DaySummary = daySummary
    }
    
    init(dictionary: NSDictionary) {
        let currently = dictionary["currently"] as? NSDictionary
        let minutely = dictionary["minutely"] as? NSDictionary
        let daily = dictionary["daily"] as? NSDictionary
        let currentTemp = currently!["temperature"] as? Double
        let currentSummary = minutely!["summary"] as? String
        let preciptChance = currently!["precipProbability"] as? Double
        let windSpeed = currently!["windSpeed"] as? Double
        let days = daily!["data"] as? [NSDictionary]
        var highs = [Double]()
        var lows = [Double]()
        var summaries = [String]()
        for day in days!{
            let high = day["temperatureMax"] as? Double
            highs.append(high!)
            let low = day["temperatureMin"] as? Double
            lows.append(low!)
            let summary = day["summary"] as? String
            summaries.append(summary!)
        }
        CurrentTemp = currentTemp!
        CurrentSummary = currentSummary!
        PrecipChance = preciptChance!
        WindSpeed = windSpeed!
        HighTemp = highs
        LowTemp = lows
        DaySummary = summaries
    }
    
}
```

There are three static classes that are used to 
capture data

The first is the API Helper class, this is used to convert
a file with our Forecast.io and google api keys to ensure it does not
end up on github.
``` swift
class ApiKeyHelper { 
   static func getKey(appName: String) -> String { 
        let path = NSBundle.mainBundle().pathForResource(appName, ofType: "apikey") 
       let key = try? String(contentsOfFile: path!) 
       print("key \(key)") 
       return key! 
   } 
} 

```
the second makes a call to forecast.io's api address
with the information from the iPhone's location service
``` swift
class ForecastHelper { 



 
   private static let key = ApiKeyHelper.getKey("Forecast") 
   static var weather: Weather? 
    
     static func getWeather(completionHandler:(weather: Weather) -> ()) { 
          
         let urlString = "https://api.forecast.io/forecast/\(key)/\(Location.lat),\(Location.long)" 
         let url = NSURL(string: urlString) 
         let request = NSMutableURLRequest(URL: url!) 
         let session = NSURLSession.sharedSession() 
         let task = session.dataTaskWithRequest(request) { res, data, err in 
             let json = try? NSJSONSerialization.JSONObjectWithData(res!, options: .MutableContainers) 
             let jsonDict = json as! NSDictionary 
             weather = Weather(dictionary: jsonDict) 
             completionHandler(weather: weather!) 
         } 
         task.resume() 
     } 
      
 
 
 } 
```
finally we have the Location class, this calls to the iPhone
to leverage the location service and captures a lat and long
it then makes a call to Google's reverse geolocation service
to populate the text version of our user's location
``` swift 
class Location { 
    
   static var lat = 44.98 
   static var long = -93.25 
   static private var key = ApiKeyHelper.getKey("Google") 
    
     static func updateLocation(location: CLLocation, completionHandler:(placeName: String) -> ()) { 
             lat = location.coordinate.latitude 
             long = location.coordinate.longitude 
         reverseGeocode(lat, long: long) { response in 
             completionHandler(placeName: response) 
         } 
     } 
      
     static func reverseGeocode(lat: Double, long: Double, completionHandler:(place: String) -> ()) { 
             let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(long)&key=\(key)" 
         print(urlString) 
             let url = NSURL(string: urlString) 
             let request = NSMutableURLRequest(URL: url!) 
             let session = NSURLSession.sharedSession() 
             let task = session.dataTaskWithRequest(request) { res, data, err in 
                 let json = try? NSJSONSerialization.JSONObjectWithData(res!, options: .AllowFragments) 
                 let jsonDict = json as! NSDictionary 
                 let results = jsonDict["results"] as! NSArray 
                 let components = results[1] as! NSDictionary 
                 let longName = components["formatted_address"] as! String 
                 let index = longName.characters.count - 5 
                 let shortName = longName.stringByPaddingToLength(index, withString: "", startingAtIndex: 0) 
                 print(shortName) 
                 completionHandler(place: shortName) 
             } 
             task.resume() 
          
     } 
 } 
```

when the main view loads, it first calls for the location
by requesting authorization from the user, if the user
has provided this previously (only possible from the iPhone)
it will not prompt a second time.  It then sets the 
accuracy to within 100m and requests the service.
at the end of this function we start the spin animation
to indicate to the user the application is thinking.
``` swift
override func awakeWithContext(context: AnyObject?) { 
       super.awakeWithContext(context) 
       lm.delegate = self 
       lm.requestAlwaysAuthorization() 
       lm.desiredAccuracy = kCLLocationAccuracyHundredMeters 
       lm.requestLocation() 
       spin() 
    } 

```
These two methods of the locationManger protocol will set the
view's location object as the location provided by the iPhone
``` swift
func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) { 
       currentLocation = newLocation 
        
   } 
    
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { 
       currentLocation = locations[0] 
    } 

```
if the property is set and not nil, the event then sets the
location in the static Location object
this returns both the location name and the weather object
both in async methods since both are web calls
``` swift
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

```
once the weather object has been set, and is not nil
we use the information to populate the text fields
and stop the spin animation and unhide the button
``` swift 
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
```
