import Foundation
import CoreLocation

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

