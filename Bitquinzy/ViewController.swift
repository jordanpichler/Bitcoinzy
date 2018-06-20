//
//  FirstViewController.swift
//  Bitcoinzy
//
//  Created by Jordan Pichler on 07/04/2017.
//  Copyright © 2018 Jordan A. Pichler. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Charts

// Always name ViewControllers after their purpose
// E.g BitcoinOverviewViewController
class ViewController: UIViewController {
    
    // All labels containing variable values
    @IBOutlet weak var rateDisplayLabel: UILabel!
    @IBOutlet weak var openDisplayLabel: UILabel!
    @IBOutlet weak var highDisplayLabel: UILabel!
    @IBOutlet weak var lowDisplayLabel: UILabel!
    @IBOutlet weak var volumeDisplayLabel: UILabel!
    @IBOutlet weak var volumePercDisplayLabel: UILabel!
    
    @IBOutlet weak var historyView: LineChartView!
    @IBOutlet var timeFrameSelection: [UIButton]!
    
    // Arrays of data fetched on launch
    var yearData: [Dictionary<String, Any>] = []    // daily data for year
    var minuteData: [Dictionary<String, Any>] = []  // minutely data for past 24h
    // can be written more elgantly as
    // var yearData = [[String: Any]]()
    
    /*
        I always like to group functions into 
        * UIViewController lifecycle (viewDidLoad, viewWillAppear...) + styling (layoutViews = setUpLabels)
        * Container management (if necessary) (willMoveToParentViewController, didMoveToParentViewController)
        * IBActions
        * logic: updateChart(), ...
        * networking
     */
    
    /*
        In General it makes sense to have the model separated from the viewControllers, so an own networking class, bitcoinRateDataObject, ....
        This makes apps much more scalable and easier to maintain. In this case of a simple one-view app, your approach is probably the easiest, but still, not easy to extend in case you want to add new screens to your app.
     */
    
    
    @IBAction func onChangeTimeFrame(_ sender: UIButton) {
        for button in timeFrameSelection {
            button.isSelected = false
        }
        sender.isSelected = !sender.isSelected
        
        // Extract certain values from yearData
        var dataSection: [Dictionary<String, Any>] = []
        var days = 0
        var resectionize = true

        // If empty, JSON download failed before
        let yearDataExists = (yearData.count > 0)
        let minuteDataExists = (minuteData.count > 0)
        
        switch sender.currentTitle! {
        case "Y":
            resectionize = false
            dataSection = yearData
        case "6M":
            days = 180
        case "3M":
            days = 90
        case "M":
            days = 30
        case "W":
            days = 7
        case "D":
            resectionize = false
            dataSection = minuteData
        default:
            print("unknown Button touched")
        }
        //<-- This is dangerous. Never use the title of a button to identify which action should be done. This will run into issues eventually - latest if you want to localize an app, where "Y"("Year") is e.g. "J"("Jahr")
        // Why not have an IBAction for every button that internally call different functions like this
        /*
         
         @IBAction func timeChangedYear(_ sender: UIButton) {
            changeTimeFrame(365)
         }
         
         ...
         
         
         func changeTimeFrame(newTimeFrameDays: Int) {
         // do stuff
         }
         
         
         */
        
        
        
        // Rebuild new array with needed days & update chart
        if yearDataExists && minuteDataExists {
            if resectionize {
                for i in 0 ..< days {
                    dataSection.append(yearData[i])
                }
            }
            updateChart(with: dataSection)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        // never forget to call super.viewWillAppear
        // it might make sense to have an enum of supported currencies so that you don't have to always use the same string (and let the compiler help you prevent mistakes)
        /*
         
         enum CurrencyType: String {
         
            case usd = "USD"
            case euro = "euro"
         
         }
         
         Then you could change your function to
         func retrieveBTCExchangeRate(for currency: CurrencyType)
         
         and prevent mistakes like calling retrieveBTCExchangeRate(for: "UDS"), instead it would be retrieveBTCExchangeRate(for: .usd)
         same for historic and minute data
         
         */
        
        retrieveBTCExchangeRate(for: "USD")
        
        // Get values for past 365 days
        let initialYear = (Date.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate) - 365*24*60*60
        // I think let d = Date(timeIntervalSinceNow: -365*24*60*60) should work as well
        // probably needs d.components.year or sth though, not sure if better, but that's what i would have done
        
        
        retrieveBTCHistoricData(for: "USD", since: Int(initialYear))
        retrieveBTCMinuteData(for: "USD")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Better remove this function if you don't need it at all

    }
   
    func updateChart(with data: [Dictionary<String, Any>]) {
        var dataEntries: [ChartDataEntry] = []

        var count = 0
        for day in data.reversed() {
            let dataEntry = ChartDataEntry(x: Double(count), y: (Double(day["value"] as! Float)))
            dataEntries.append(dataEntry)
            count = count + 1
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "History")
        
        // Format line graph
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(#colorLiteral(red: 0.003921568627, green: 0.8823529412, blue: 0.003921568627, alpha: 1))
        chartDataSet.lineWidth = chartDataSet.lineWidth * 1.5
        chartDataSet.drawValuesEnabled = false
        
        let chartData = LineChartData(dataSet: chartDataSet)

        // Remove unnecessary labels
        historyView.rightAxis.enabled = false
        historyView.chartDescription?.text = ""
        historyView.legend.enabled = false
        
        // Format axis and grids
        let xAxis = historyView.xAxis
        let yAxis = historyView.leftAxis
        yAxis.gridColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1030072774)
        xAxis.gridColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1030072774)
        xAxis.labelPosition = .bottom

        historyView.data = chartData
        
    }

    func retrieveBTCExchangeRate(for currency: String) {
        setUpdateLabels()

        let url = "https://apiv2.bitcoinaverage.com/indices/local/ticker/BTC\(currency)"
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                // Read JSON data
                let rate = json["ask"].floatValue
                let open = json["open"]["day"].floatValue
                let high = json["high"].floatValue
                let low = json["low"].floatValue
                let vol = json["volume"].floatValue
                let volPerc = json["volume_percent"].floatValue

                // Always represent rate with 2 decimals and thousand seperator
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2

                self.rateDisplayLabel.text =  formatter.string(from: NSNumber(value: rate))
                self.openDisplayLabel.text =  formatter.string(from: NSNumber(value: open))
                self.highDisplayLabel.text =  formatter.string(from: NSNumber(value: high))
                self.lowDisplayLabel.text =  formatter.string(from: NSNumber(value: low))
                self.volumeDisplayLabel.text =  formatter.string(from: NSNumber(value: vol))
                self.volumePercDisplayLabel.text =  String(format: "%.2f %%", arguments: [volPerc])
                
                /*
                    Looks good, but here you have to be careful with threading. It might happen, that Alamofire doesnt respond on main thread, but all UI changes need to be done on main thread. If not wird UI issues can occurr.
                 */
                
                
            case .failure(let error):
                print(error)
                print("Failed to retrieve current data")
            }
        }
    }
    
    func retrieveBTCMinuteData(for currency: String) {
        print("Fetching day's minutely data")
        var dateHighArray: [Dictionary<String, Any>] = []
        // this can be moved into the callback of your request i guess
        
        let url = "https://apiv2.bitcoinaverage.com/indices/local/history/BTC\(currency)?period=daily&format=json"
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print("Fetched!")
                
                let json = JSON(value)
                let dailyArray = json.arrayValue
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                
                // Create simple Array of Dictionaries containing Time and Average-value
                for day in dailyArray {
                    let dateString = (day["time"].stringValue)
                    let date = dateFormatter.date(from: dateString)
                    let value = day["average"].floatValue
                    if let time = date {
                        // FIXME: Midnight unwraps as nil!
                        dateHighArray.append(["value": value, "date": time])
                    }
                }
                
                
                self.minuteData = dateHighArray

                
                
            case .failure(let error):
                print(error)
                print("Failed to retrieve minute data")
                
            }
            for valuePair in dateHighArray {
                print(valuePair["value"]!)
                print(valuePair["date"]!)
                
            }
        }
    }

    func retrieveBTCHistoricData(for currency: String, since timestamp: Int) {
        print("Fetching Historic data")
        var dateHighArray: [Dictionary<String, Any>] = []

        let url = "https://apiv2.bitcoinaverage.com/indices/local/history/BTC\(currency)?since=\(timestamp)"
        Alamofire.request(url, method: .get).validate().responseJSON { response in

            switch response.result {
            case .success(let value):
                print("Fetched!")

                let json = JSON(value)
                let dailyArray = json.arrayValue
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                
                // Create simple Array of Dictionaries containing Date and High-value
                for day in dailyArray {
                    let dateString = (day["time"].stringValue)
                    let date = dateFormatter.date(from: dateString)
                    let value = day["high"].floatValue
                    
                    dateHighArray.append(["value": value, "date": date!])
                }
                
                self.updateChart(with: dateHighArray)
                self.yearData = dateHighArray

                
            case .failure(let error):
                print(error)
                print("Failed to retrieve year data")

            }
        }
    }
    
    private func setUpdateLabels() {
        self.rateDisplayLabel.text =  "updating..."
        self.rateDisplayLabel.text =  "..."
        self.openDisplayLabel.text =  "..."
        self.highDisplayLabel.text =  "..."
        self.lowDisplayLabel.text =  "..."
        self.volumeDisplayLabel.text = "..."
        self.volumePercDisplayLabel.text = "..."
    }
}

