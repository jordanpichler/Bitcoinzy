//
//  BitcoinOverviewViewController.swift
//  Bitcoinzy
//
//  Created by Jordan Pichler on 20/06/2018.
//  Copyright © 2018 Jordan A. Pichler. All rights reserved.
//

import UIKit

class BitcoinOverviewViewController: UIViewController {

    var header = HeaderTitle()
    var valueSection = ValueContainerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()    
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        // Add header & value section
        view.addSubview(header)
        view.addSubview(valueSection)
        
        view.addConstraintsWithFormat(format: "V:|[v0]-25-[v1]|", views: header, valueSection)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: header)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: valueSection)
        
    }
}
