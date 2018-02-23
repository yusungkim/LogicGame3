//
//  MatrixViewCell.swift
//  LogicGame3
//
//  Created by KimYusung on 2017/12/10.
//  Copyright © 2017 yusungkim. All rights reserved.
//

import UIKit

class MatrixViewCell: UICollectionViewCell {
    @IBOutlet weak var hintLabel: UILabel!
    var cellMark: Cell? {
        didSet {
            // clear label
            hintLabel.text = nil
            
            // marking
            switch cellMark! {
            case .marked:
                backgroundColor = UIColor.black
            case .blank:
                backgroundColor = UIColor.white
            case .unknown:
                backgroundColor = UIColor.lightGray
            }
        }
    }
    var hint: Int? {
        didSet {
            if hint != nil {
                let hintValue = CGFloat(hint!)
                hintLabel.text = hint!.description
                
                let colorMax: CGFloat = 5.0
                
                // set yellow
                var redComponent: CGFloat = 1.0
                var greenComponent: CGFloat = 1.0
                var blueComponent: CGFloat = 0.0
                
                // yellow(1.0, 1.0, 0.0) -> red(1.0, 0.0, 0.0)
                if hintValue < colorMax {
                    redComponent = 1.0
                    greenComponent = 1.0 - hintValue.truncatingRemainder(dividingBy: colorMax) / colorMax
                    blueComponent = 0.0
                }
                
                // red(1.0, 0.0, 0.0) -> magenta (1.0, 0.0, 1.0)
                if hintValue >= colorMax && hintValue < colorMax * 2 {
                    redComponent = 1.0
                    greenComponent = 0.0
                    blueComponent = hintValue.truncatingRemainder(dividingBy: colorMax) / colorMax
                }
                
                // green(0.0, 1.0, 0.0) -> cyan(0.0, 1,0, 1.0)
                if hintValue >= colorMax * 2 {
                    redComponent = 0.0
                    greenComponent = 1.0
                    blueComponent = hintValue.truncatingRemainder(dividingBy: colorMax) / colorMax
                }
                backgroundColor = UIColor.init(red: redComponent, green: greenComponent, blue: blueComponent, alpha: 0.8)
            } else {
                hintLabel.text = nil
                backgroundColor = UIColor.clear
            }
        }
    }
}
