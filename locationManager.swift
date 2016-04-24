import Foundation
import CoreLocation

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

