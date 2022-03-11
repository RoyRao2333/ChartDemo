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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
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
                    $0.backgroundColor = UIColor.systemBlue.cgColor
                } else {
                    $0.backgroundColor = UIColor(hex: "#9169e5")?.cgColor
                }
            }
        }
        
        let count = tappedLayerName.replacingOccurrences(of: "CB", with: "")
        NotificationCenter.default.post(name: .tapChanged, object: self, userInfo: ["count": count])
    }
}


extension BarChartView {
    
    func updateView(with model: BarChartModel) {
        mainLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        mainLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: frame.size.width,
            height: frame.size.height
        )
        
        showHorizontalLines(lines: model.horizontalLines)
        
        for (index, entry) in model.barEntries.enumerated() {
            addBar(index: index, entry: entry, oldEntry: nil)
        }
        
        
        let newPoints = getControlPoints(for: model.barEntries)
        
        mainLayer.addCurvedLineLayer(
            points: newPoints,
            color: UIColor(hex: "#e164b4")?.cgColor,
            lineWidth: 3,
            oldPoints: []
        )
    }
}


extension BarChartView {
    
    private func setup() {
        layer.addSublayer(mainLayer)
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
                color: UIColor(hex: "#a5afb9")?.cgColor,
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
            color: UIColor(hex: "#9169e5")?.cgColor,
            cornerRadius: 4,
            maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
            animated: animated,
            oldFrame: oldEntry?.barFrame
        )
        
        mainLayer.addTextLayer(
            frame: entry.dateLabelFrame,
            color: UIColor(hex: "#a5afb9")?.cgColor,
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
        points.append(CGPoint(x: frame.maxX, y: baseLineY))
        
        return points
    }
}
