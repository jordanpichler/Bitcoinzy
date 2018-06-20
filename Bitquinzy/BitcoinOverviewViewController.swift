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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    
        view.addSubview(header)
        view.addConstraintsWithFormat(format: "V:|[v0]", views: header)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: header)
        header.setupConstraints()
    }
}
