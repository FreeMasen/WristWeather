import Foundation

class ApiKeyHelper {
    static func getKey(appName: String) -> String {
        let path = NSBundle.mainBundle().pathForResource(appName, ofType: "apikey")
        let key = try? String(contentsOfFile: path!)
        print("key \(key)")
        return key!
    }
}