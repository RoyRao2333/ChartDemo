//
//  DataEntry.swift
//
//  Created by roy on 2022/3/8.
//

import UIKit

struct DataEntry: HashableSynthesizable, Identifiable {
    var id: String { date }
    
    let value: Int
    let date: String
    let barColor: UIColor
    let barHeightPer: CGFloat
}
