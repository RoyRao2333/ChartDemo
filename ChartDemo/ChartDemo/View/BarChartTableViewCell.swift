//
//  BarChartTableViewCell.swift
//  ChartDemo
//
//  Created by roy on 2022/3/10.
//

import UIKit
import Combine

class BarChartTableViewCell: UITableViewCell {
    @IBOutlet private weak var barChartView: BarChartView!
    @IBOutlet private var countLabel: UILabel!
    
    private var subscriber: AnyCancellable?
    private let leadingSpacing: CGFloat = 40
    private let bottomSpacing: CGFloat = 40
    private let barWidth: CGFloat = 10

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setObservation()
    }
}


// MARK: Shared Methods -
extension BarChartTableViewCell {
    
    func updateInfo(with dataEntries: [DataEntry]) {
        guard !dataEntries.isEmpty else { return }
        let values = dataEntries.map { $0.value }
        guard let maxValue = values.max() ?? values.sorted(by: >).first else { return }
        
        let barEntries = generateBarEntries(dataEntries: dataEntries, contentSize: barChartView.frame.size)
        let lines = generateHorizontalLines(maxValue: maxValue, contentSize: barChartView.frame.size)
        let model = BarChartModel(barEntries: barEntries, horizontalLines: lines, maxValue: maxValue)
        barChartView.updateView(with: model)
    }
}


// MARK: Private Methods -
extension BarChartTableViewCell {
    
    private func setObservation() {
        subscriber = NotificationCenter.default
            .publisher(for: .tapChanged, object: barChartView)
            .compactMap { $0.userInfo as? [String: String] }
            .compactMap { $0["count"] }
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: countLabel)
    }
    
    private func generateBarEntries(dataEntries: [DataEntry], contentSize: CGSize) -> [BarEntry] {
        var result: [BarEntry] = []
        
        let barSpacing = (contentSize.width - leadingSpacing - CGFloat(dataEntries.count) * barWidth) / CGFloat(dataEntries.count + 1)
        
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
        
        return result
    }
    
    private func generateHorizontalLines(maxValue: Int, contentSize: CGSize) -> [HorizontalLine] {
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
        
        return result
    }
    
    private func getPeak(by value: Int) -> Int {
        if value <= 20 {
            return 20
        } else if value % 5 == 0 && value % 4 == 0 {
            return value
        }
        
        let result = (value / 20 + 1) * 20
        return result
    }
}
