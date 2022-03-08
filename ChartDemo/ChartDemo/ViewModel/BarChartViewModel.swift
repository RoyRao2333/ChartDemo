//
//  BarChartViewModel.swift
//  ChartDemo
//
//  Created by roy on 2022/3/7.
//

import UIKit
import Combine

class BarChartViewModel {
    let barEntries = CurrentValueSubject<[BarEntry], Never>([])
    let horizontalLines = PassthroughSubject<[HorizontalLine], Never>()
    
    private let bottomSpacing: CGFloat = 40
    let barWidth: CGFloat
    let barSpacing: CGFloat
    
    var chartViewContentWidth: CGFloat {
        (barWidth + barSpacing) * CGFloat(barEntries.value.count) + barSpacing
    }
    
    init(barWidth: CGFloat = 40, barSpacing: CGFloat = 20) {
        self.barWidth = barWidth
        self.barSpacing = barSpacing
    }
}


extension BarChartViewModel {
    
    func generateBarEntries(dataEntries: [DataEntry], contentHeight: CGFloat) {
        var result: [BarEntry] = []
        
        for (index, entry) in dataEntries.enumerated() {
            let entryHeight = CGFloat(entry.barHeightPer) * (contentHeight - bottomSpacing)
            let xPosition: CGFloat = barSpacing + CGFloat(index) * (barWidth + barSpacing)
            let yPosition: CGFloat = contentHeight - bottomSpacing - entryHeight
            let origin = CGPoint(x: xPosition, y: yPosition)
            
            let barEntry = BarEntry(
                barOrigin: origin,
                barWidth: barWidth,
                barHeight: entryHeight,
                barSpacing: barSpacing,
                data: entry
            )
            result.append(barEntry)
        }
        
        barEntries.send(result)
    }
    
    func generateHorizontalLines(maxValue: Int, contentHeight: CGFloat) {
        var result: [HorizontalLine] = []
        
        let peak = getPeak(by: maxValue)
        let horizontalLineValues: [Int] = [
            0,
            peak / 4,
            peak / 2,
            peak / 4 * 3,
            peak
        ]
        
        for (index, lineValue) in horizontalLineValues.enumerated() {
            let yPosition = contentHeight - bottomSpacing - CGFloat(index) / CGFloat(4) * (contentHeight - bottomSpacing)
            let lineSegment = BarLineSegment(
                value: lineValue,
                startPoint: CGPoint(x: 0, y: yPosition),
                endPoint: CGPoint(x: chartViewContentWidth, y: yPosition)
            )
            let line = HorizontalLine(width: 0.5, segment: lineSegment)
            
            result.append(line)
        }
        
        horizontalLines.send(result)
    }
}


extension BarChartViewModel {
    
    private func getPeak(by value: Int) -> Int {
        if value <= 20 {
            return 20
        } else if value % 5 == 0 || value % 4 == 0 {
            return value
        }
        
        return (value / 20 + 1) * 20
    }
}
