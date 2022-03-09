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
    private let leadingSpacing: CGFloat = 40
    let barWidth: CGFloat
    let barCount: Int
    
    var contentSize: CGSize = .zero
    
    init(barWidth: CGFloat = 40, barCount: Int = 7) {
        self.barWidth = barWidth
        self.barCount = barCount
    }
}


extension BarChartViewModel {
    
    func generateBarEntries(dataEntries: [DataEntry], contentSize: CGSize) {
        self.contentSize = contentSize
        var result: [BarEntry] = []
        
        let barSpacing = (contentSize.width - leadingSpacing - CGFloat(dataEntries.count) * barWidth) / CGFloat(barCount + 1)
        
        for (index, entry) in dataEntries.enumerated() {
            let entryHeight = CGFloat(entry.barHeightPer) * (contentSize.height - bottomSpacing)
            let xPosition: CGFloat = leadingSpacing + barSpacing + CGFloat(index) * (barWidth + barSpacing)
            let yPosition: CGFloat = contentSize.height - bottomSpacing - entryHeight
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
    
    func generateHorizontalLines(maxValue: Int) {
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
            let yPosition = contentSize.height - bottomSpacing - CGFloat(index) / CGFloat(4) * (contentSize.height - bottomSpacing)
            let lineSegment = BarLineSegment(
                value: lineValue,
                startPoint: CGPoint(x: leadingSpacing, y: yPosition),
                endPoint: CGPoint(x: contentSize.width, y: yPosition)
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
