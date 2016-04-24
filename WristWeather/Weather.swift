import Foundation

class Weather {
    
    var CurrentTemp: Double
    var CurrentSummary: String
    var PrecipChance: Double
    var WindSpeed: Double
    var HighTemp: [Double]
    var LowTemp: [Double]
    var DaySummary: [String]
    
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