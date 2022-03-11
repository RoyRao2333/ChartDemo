//
//  BarChartModel.swift
//  ChartDemo
//
//  Created by roy on 2022/3/11.
//

import UIKit

struct BarChartModel: HashableSynthesizable {
    let barEntries: [BarEntry]
    let horizontalLines: [HorizontalLine]
    let maxValue: Int
}
