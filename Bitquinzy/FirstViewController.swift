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

class FirstViewController: UIViewController {

    @IBOutlet weak var rateDisplayLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveBTCExchangeRate(for: "USD")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
}

