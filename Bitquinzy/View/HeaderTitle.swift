//
//  HeaderTitle.swift
//  Bitcoinzy
//
//  Created by Jordan Pichler on 20/06/2018.
//  Copyright © 2018 Jordan A. Pichler. All rights reserved.
//

import UIKit

/**
 Contains a bold title label and a seperator line right below it.
 */
class HeaderTitle: UIView {

    var title: UILabel = {
        let label = UILabel()
        label.text = "HeaderTitle"
        label.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        return label
    }()
    
    var seperatorLine: UIView = {
        let line = UIView(frame: CGRect.zero)
        line.backgroundColor = .gray
        return line
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(title)
        addSubview(seperatorLine)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: title)
        addConstraintsWithFormat(format: "H:|-20-[v0]-20-|", views: seperatorLine)
        addConstraintsWithFormat(format: "V:|-45-[v0]-[v1(1)]|", views: title, seperatorLine)
    }
}
