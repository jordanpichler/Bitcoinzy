//
//  ValueView.swift
//  Bitcoinzy
//
//  Created by Jordan Pichler on 20/06/2018.
//  Copyright © 2018 Jordan A. Pichler. All rights reserved.
//

import UIKit

/**
 View containing a title and a value (e.g. exchange rate & 123.45)
 */
class ValueView: UIView {

    // MARK: - Properties -
    
    var title = "Title" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var value: Float = 123.45{
        didSet {
            valueLabel.text = "\(value)"
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.text = "\(value)"
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.textColor = .green
        return label
    }()
    
    // MARK: - Initializers -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(valueLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Because who uses IB?")
    }
    
    /**
        Initalizes and sets respective values.
        - Parameters:
            - title: Text that will be set above value.
            - value: Numeric value displayed below title.
     */
    convenience init(title: String, value: Float) {
        self.init()
        self.title = title
        self.value = value
    }
    
    func setupConstraints() {
        addConstraintsWithFormat(format: "H:|[v0]", views: titleLabel)
        addConstraintsWithFormat(format: "H:|[v0]", views: valueLabel)
        addConstraintsWithFormat(format: "V:|[v0]-[v1]|", views: titleLabel, valueLabel)
    }
}
