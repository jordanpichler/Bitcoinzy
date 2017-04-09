//
//  FirstViewController.swift
//  Bitquinzy
//
//  Created by Jordan Pichler on 07/04/2017.
//  Copyright © 2017 Jordan A. Pichler. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Charts

class FirstViewController: UIViewController {
    
    // All labels containing variable values
    @IBOutlet weak var rateDisplayLabel: UILabel!
    @IBOutlet weak var openDisplayLabel: UILabel!
    @IBOutlet weak var highDisplayLabel: UILabel!
    @IBOutlet weak var lowDisplayLabel: UILabel!
    @IBOutlet weak var volumeDisplayLabel: UILabel!
    @IBOutlet weak var volumePercDisplayLabel: UILabel!
    
    
    @IBOutlet weak var historyView: LineChartView!
    @IBOutlet var timeFrameSelection: [UIButton]!
    var yearData: [Dictionary<String, Any>] = []
    
    @IBAction func onChangeTimeFrame(_ sender: UIButton) {
        for button in timeFrameSelection {
            button.isSelected = false
        }
        sender.isSelected = !sender.isSelected
        
        // Extract certain values from yearData
        var dataSection: [Dictionary<String, Any>] = []
        var days = 0
        var resectionize = true

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
            // TODO fetch hourly data
        default:
            print("unknown Button touched")
        }
        
        if resectionize {
            for i in 0 ..< days {
                dataSection.append(yearData[i])
            }
        }
        
        updateChart(with: dataSection)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveBTCExchangeRate(for: "USD")
        
        let initialYear = (Date.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate) - 365*24*60*60
        retrieveBTCHistoricData(for: "USD", since: Int(initialYear))

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
   
    
        
    
    func updateChart(with data: [Dictionary<String, Any>]) {
        var dataEntries: [ChartDataEntry] = []

        var count = 0
        for day in data.reversed() {
            let dataEntry = ChartDataEntry(x: Double(count), y: (Double(day["value"] as! Float)))
            dataEntries.append(dataEntry)
            count = count + 1
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Year history")
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(NSUIColor.green)
        chartDataSet.lineWidth = chartDataSet.lineWidth * 2
        //print("Line: \(chartDataSet.lineWidth)")
        let chartData = LineChartData(dataSet: chartDataSet)
        historyView.legend.enabled = false
        historyView.rightAxis.enabled = false
        
        historyView.data = chartData
        //historyView.animate(xAxisDuration: 3000)
        
    }
    

    func retrieveBTCExchangeRate(for currency: String) {
        self.rateDisplayLabel.text =  "updating..."
        self.rateDisplayLabel.text =  "..."
        self.openDisplayLabel.text =  "..."
        self.highDisplayLabel.text =  "..."
        self.lowDisplayLabel.text =  "..."
        self.volumeDisplayLabel.text = "..."
        self.volumePercDisplayLabel.text = "..."

        let url = "https://apiv2.bitcoinaverage.com/indices/local/ticker/BTC\(currency)"
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                // always represent rate with 2 decimals
                let rate = json["ask"].floatValue
                let open = json["open"]["day"].floatValue
                let high = json["high"].floatValue
                let low = json["low"].floatValue
                let vol = json["volume"].floatValue
                let volPerc = json["volume_percent"].floatValue

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

                
            case .failure(let error):
                print(error)
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
                print("Failed!")

            }
            for valuePair in dateHighArray {
               print(valuePair["value"]!)
               print(valuePair["date"]!)

            }
        }
    }

}

