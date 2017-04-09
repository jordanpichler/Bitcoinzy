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
    
    @IBOutlet weak var rateDisplayLabel: UILabel!
    @IBOutlet weak var historyView: LineChartView!
    @IBOutlet var timeFrameSelection: [UIButton]!
    
    @IBAction func onChangeTimeFrame(_ sender: UIButton) {
        for button in timeFrameSelection {
            button.isSelected = false
        }
        sender.isSelected = !sender.isSelected
        
        var timeFrame = Date.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1970AndReferenceDate
        
        switch sender.currentTitle! {
        case "Y":
            timeFrame = timeFrame - (365*24*60*60)
        case "6M":
            timeFrame = timeFrame - (183*24*60*60)
        case "3M":
            timeFrame = timeFrame - (90*24*60*60)
        case "M":
            timeFrame = timeFrame - (31*24*60*60)
        case "W":
            timeFrame = timeFrame - (7*24*60*60)
        case "D":
            timeFrame = timeFrame - (24*60*60)
        default:
            print("unknown Button touched")
        }
        
        retrieveBTCHistoricData(for: "USD", since: Int(timeFrame))

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
        let chartData = LineChartData(dataSet: chartDataSet)
        historyView.data = chartData
        
    }
    

    func retrieveBTCExchangeRate(for currency: String) {
        self.rateDisplayLabel.text =  "updating..."

        let url = "https://apiv2.bitcoinaverage.com/indices/local/ticker/BTC\(currency)"
        Alamofire.request(url, method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                // always represent rate with 2 decimals
                let rate = json["ask"].floatValue
                self.rateDisplayLabel.text =  String(format: "%.2f", arguments: [rate])
                
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

