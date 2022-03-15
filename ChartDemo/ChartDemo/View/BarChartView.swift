//
//  BarChartView.swift
//  ChartDemo
//
//  Created by roy on 2022/3/8.
//

import UIKit
import Combine

class BarChartView: UIView {
    private let mainLayer = CALayer()
    private let leadingSpacing: CGFloat = 40
    private let bottomSpacing: CGFloat = 40
    private let barWidth: CGFloat = 15
    
    var dataEntries: [DataEntry] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    override func draw(_ rect: CGRect) {
        if !dataEntries.isEmpty {
            generateModel(with: dataEntries)
        }
        
        super.draw(rect)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let point = touches.first?.location(in: self),
            let tappedLayer = mainLayer.hitTest(point),
            let tappedLayerName = tappedLayer.name,
            let sublayers = mainLayer.sublayers
        else { return }
        
        if tappedLayer == mainLayer { return }
        
        sublayers.forEach {
            if
                let layerName = $0.name,
                layerName.starts(with: "CB")
            {
                if $0 == tappedLayer {
                    $0.backgroundColor = UIColor(hex: "#755EFF")?.cgColor
                    
                    sublayers.filter({ $0.name == "dotLayer" }).forEach { $0.removeFromSuperlayer() }
                    
                    mainLayer.addCircleLayer(
                        frame: CGRect(
                            x: $0.frame.origin.x + $0.frame.width / 8,
                            y: $0.frame.origin.y - $0.frame.width / 2,
                            width: $0.frame.width / 4 * 3,
                            height: $0.frame.width / 4 * 3
                        ),
                        name: "dotLayer",
                        fillColor: UIColor(hex: "#755EFF")?.cgColor,
                        borderColor: UIColor.white.cgColor,
                        borderWidth: 1,
                        shadowOpacity: 1,
                        shadowRadius: 6,
                        shadowOffset: CGSize(width: 0, height: 3),
                        shadowColor: UIColor(hex: "#755EFF")?.cgColor
                    )
                } else {
                    $0.backgroundColor = UIColor(hex: "#E9D6FB")?.cgColor
                }
            }
        }
        
        let count = tappedLayerName.replacingOccurrences(of: "CB", with: "")
        NotificationCenter.default.post(name: .tapChanged, object: self, userInfo: ["count": count])
    }
}


// MARK: Private Methods -
extension BarChartView {
    
    private func setup() {
        layer.addSublayer(mainLayer)
    }
    
    private func generateModel(with dataEntries: [DataEntry]) {
        guard !dataEntries.isEmpty else { return }
        let values = dataEntries.map { $0.value }
        let maxValue = values.max() ?? 0
        
        let barEntries = generateBarEntries(dataEntries: dataEntries)
        let lines = generateHorizontalLines(maxValue: maxValue)
        let model = BarChartModel(barEntries: barEntries, horizontalLines: lines, maxValue: maxValue)
        
        updateView(with: model)
    }
    
    private func updateView(with model: BarChartModel) {
        mainLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        mainLayer.frame = bounds
        
        showHorizontalLines(lines: model.horizontalLines)
        
        for (index, entry) in model.barEntries.enumerated() {
            addBar(index: index, entry: entry, oldEntry: nil)
        }
        
        
        let newPoints = getControlPoints(for: model.barEntries)
        
        mainLayer.addCurvedLineLayer(
            points: newPoints,
            color: UIColor(hex: "#755EFF")?.cgColor,
            lineWidth: 2,
            oldPoints: []
        )
    }
    
    private func generateBarEntries(dataEntries: [DataEntry]) -> [BarEntry] {
        var result: [BarEntry] = []
        
        let contentRect = bounds
        let barSpacing = (contentRect.width - leadingSpacing - CGFloat(dataEntries.count) * barWidth) / CGFloat(dataEntries.count + 1)
        
        for (index, entry) in dataEntries.enumerated() {
            let entryHeight = CGFloat(entry.barHeightPer) * (contentRect.height - bottomSpacing)
            let xPosition: CGFloat = leadingSpacing + barSpacing + CGFloat(index) * (barWidth + barSpacing)
            let yPosition: CGFloat = contentRect.height - bottomSpacing - entryHeight
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
    
    private func generateHorizontalLines(maxValue: Int) -> [HorizontalLine] {
        var result: [HorizontalLine] = []
        
        let contentRect = bounds
        let peak = getPeak(by: maxValue)
        let horizontalLineValues: [Int] = [
            0,
            peak / 4,
            peak / 2,
            peak / 4 * 3,
            peak
        ]
        
        for (index, lineValue) in horizontalLineValues.enumerated() {
            let yPosition = contentRect.height - bottomSpacing - CGFloat(index) / CGFloat(4) * (contentRect.height - bottomSpacing)
            let lineSegment = BarLineSegment(
                value: lineValue,
                startPoint: CGPoint(x: leadingSpacing, y: yPosition),
                endPoint: CGPoint(x: contentRect.maxX, y: yPosition)
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
    
    private func showHorizontalLines(lines: [HorizontalLine]) {
        layer.sublayers?.forEach {
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        }
        
        lines.forEach { line in
            mainLayer.addLineLayer(
                lineSegment: line.segment,
                color: UIColor.separator.cgColor,
                lineWidth: line.width,
                isDashed: false,
                animated: false,
                oldSegment: nil
            )
            
            mainLayer.addTextLayer(
                frame: CGRect(x: 0, y: line.segment.startPoint.y - 11, width: 30, height: 22),
                color: UIColor(hex: "#A7B0BE")?.cgColor,
                fontSize: 14,
                text: "\(line.segment.value)",
                animated: false,
                oldFrame: nil
            )
        }
    }
    
    private func addBar(index: Int, entry: BarEntry, oldEntry: BarEntry? = nil, animated: Bool = true) {
        mainLayer.addRectangleLayer(
            frame: entry.barFrame,
            name: "CB\(entry.data.value)",
            color: UIColor(hex: "#E9D6FB")?.cgColor,
            cornerRadius: 4,
            maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
            animated: animated,
            oldFrame: oldEntry?.barFrame
        )
        
        mainLayer.addTextLayer(
            frame: entry.dateLabelFrame,
            color: UIColor(hex: "#A7B0BE")?.cgColor,
            fontSize: 14,
            text: entry.data.date,
            animated: animated,
            oldFrame: oldEntry?.dateLabelFrame
        )
    }
    
    private func getControlPoints(for entries: [BarEntry]) -> [CGPoint] {
        guard let firstEntry = entries.first else { return [] }

        var points: [CGPoint] = []

        entries.forEach {
            points.append($0.barOrigin)
            points.append(CGPoint(x: $0.barOrigin.x + $0.barWidth, y: $0.barOrigin.y))
        }

        let baseLineY = firstEntry.barOrigin.y + firstEntry.barHeight
        points.insert(CGPoint(x: 40, y: baseLineY), at: 0)
        points.append(CGPoint(x: bounds.maxX, y: baseLineY))

        return points
    }
}
