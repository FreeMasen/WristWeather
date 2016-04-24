import Foundation
import WatchKit
class DayView: WKInterfaceController {
    
    @IBOutlet var dayForecast: WKInterfaceLabel!
    @IBOutlet var dayHigh: WKInterfaceLabel!
    @IBOutlet var dayLow: WKInterfaceLabel!
    @IBOutlet var leftButton: WKInterfaceButton!
    @IBOutlet var rightButton: WKInterfaceButton!
    
    var day = 1
    var weather: Weather? {
        didSet {
            if weather != nil {
                UpdateView(day)
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let context = context as? NSDictionary {
            day = context["day"] as! Int
            weather = context["weather"] as? Weather
        }
        
    }
    func UpdateView(day: Int) {
        setTitle()
        updateButtons()
        dayForecast.setText(weather!.DaySummary[day])
        dayHigh.setText("\(weather!.HighTemp[day])°")
        dayLow.setText("\(weather!.LowTemp[day])°")
    }
    
    func updateButtons() {
        if day <= 1 {
            leftButton.setHidden(true)
            rightButton.setRelativeWidth(1.00, withAdjustment: 0)
        } else if day >= ((weather?.DaySummary.count)!-1) {
            rightButton.setHidden(true)
            leftButton.setRelativeWidth(1.0, withAdjustment: 0)
        } else {
            rightButton.setHidden(false)
            leftButton.setHidden(false)
            rightButton.setRelativeWidth(0.5, withAdjustment: 0)
            leftButton.setRelativeWidth(0.5, withAdjustment: 0)
        }
    }
    
    func setTitle() {
        var dayName: String
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let currentDay = calendar?.component(.Weekday, fromDate: NSDate())
        var DateToDisplay = currentDay!.advancedBy(day)
        if DateToDisplay > 7 {
            DateToDisplay -= 7
        }
        switch DateToDisplay {
        case 1:
            dayName = "Sunday"
            break;
        case 2:
            dayName = "Monday"
            break;
        case 3:
            dayName = "Tuesday"
            break;
        case 4:
            dayName = "Wednesday"
            break;
        case 5:
            dayName = "Thursday"
            break;
        case 6:
            dayName = "Friday"
            break;
        case 7:
            dayName = "Saturday"
            break;
        default:
            dayName = ""
        }
        let date = calendar?.dateByAddingUnit(.Day, value: day, toDate: NSDate(), options: NSCalendarOptions.MatchFirst)
        let displayDate = formatter.stringFromDate(date!)
        self.setTitle("\(dayName) \(displayDate)")
        
    }
    
    @IBAction func touchRight() {
        day += 1
        UpdateView(day)
    }
    
    @IBAction func touchLeft() {
        day -= 1
        UpdateView(day)
    }
    
    @IBAction func dismissDayView() {
        self.dismissController()
    }
}