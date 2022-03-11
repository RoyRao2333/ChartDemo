//
//  BarEntry.swift
//
//  Created by roy on 2022/3/8.
//

import UIKit

struct BarEntry: HashableSynthesizable {
    var barOrigin: CGPoint
    var barWidth: CGFloat
    var barHeight: CGFloat
    var barSpacing: CGFloat
    var data: DataEntry
    
    var barFrame: CGRect {
        CGRect(
            x: barOrigin.x,
            y: barOrigin.y,
            width: barWidth,
            height: barHeight
        )
    }
    
    var dateLabelFrame: CGRect {
        CGRect(
            x: barOrigin.x - barSpacing / 2,
            y: barOrigin.y + barHeight + 10,
            width: barWidth + barSpacing,
            height: 22
        )
    }
}
