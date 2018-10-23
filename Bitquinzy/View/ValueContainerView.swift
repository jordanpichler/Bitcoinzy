//
//  ValueContainerView.swift
//  Bitcoinzy
//
//  Created by Jordan Pichler on 20/06/2018.
//  Copyright © 2018 Jordan A. Pichler. All rights reserved.
//

import UIKit

/**
 View containing values (e.g current rate, day's high and low, volume, ...)
 of the current state of the BTC.
 */
class ValueContainerView: UIView {
    
    // MARK: - Properties -
    
    var mainValue: ValueView!   // The big one
    var subValues: [ValueView]! // The small ones
    
    // MARK: - Initializers -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .red
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Still got no IB?")
    }
    
    convenience init(mainValue: ValueView, subValues: [ValueView]) {
        self.init()
    }

    
    
}
