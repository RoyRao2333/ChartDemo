//
//  UIBezierPathExtension.swift
//  BarChart
//
//  Created by Nguyen Vu Nhat Minh on 21/5/19.
//  Copyright © 2019 Nguyen Vu Nhat Minh. All rights reserved.
//

import UIKit

extension UIBezierPath {
    
    convenience init(lineSegment: BarLineSegment) {
        self.init()
        self.move(to: lineSegment.startPoint)
        self.addLine(to: lineSegment.endPoint)
    }
}
