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
    
    private var subscribers: Set<AnyCancellable> = []
    private let viewModel = BarChartViewModel(barWidth: 20)
    
    var barCount: Int {
        viewModel.barCount
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setObservation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
        setObservation()
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
        NotificationCenter.default.post(name: .tapChanged, object: nil, userInfo: ["count": count])
    }
}


extension BarChartView {
    
    func updateEntries(with dataEntries: [DataEntry]) {
        viewModel.generateBarEntries(dataEntries: dataEntries, contentSize: frame.size)
    }
    
    func random() {
        var result: [DataEntry] = []
        var randoms: [Int] = []
        
        (0 ..< 7).forEach { _ in
            let value = arc4random_uniform(90) + 10
            randoms.append(Int(value))
        }
        
        let max = randoms.max() ?? randoms.first!
        
        randoms.forEach { value in
            let heightPer = CGFloat(value) / CGFloat(max)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM.dd"
            let date = formatter.string(from: Date())
            
            let entry = DataEntry(
                value: Int(value),
                date: date,
                barColor: UIColor.systemPurple,
                barHeightPer: heightPer
            )
            result.append(entry)
        }
        
        updateEntries(with: result)
    }
}


extension BarChartView {
    
    private func setup() {
        layer.addSublayer(mainLayer)
    }
    
    private func setObservation() {
        viewModel.barEntries
            .withPrevious()
            .sink { [weak self] output in
                guard let weakSelf = self else { return }
                
                weakSelf.mainLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
                weakSelf.mainLayer.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: weakSelf.frame.size.width,
                    height: weakSelf.frame.size.height
                )
                
                let values = output.current.map { $0.data.value }
                if !values.isEmpty {
                    let max = values.max() ?? values.first!
                    weakSelf.showHorizontalLines(maxValue: max)
                }
                
                for (index, entry) in output.current.enumerated() {
                    let oldValue = output.previous?.safeValue(at: index)
                    weakSelf.addBar(index: index, entry: entry, oldEntry: oldValue)
                }
                
                
                let newPoints = weakSelf.getControlPoints(for: output.current)
                let oldPoints = weakSelf.getControlPoints(for: output.previous ?? [])
                
                weakSelf.mainLayer.addCurvedLineLayer(
                    points: newPoints,
                    color: UIColor(hex: "#e164b4")?.cgColor,
                    lineWidth: 3,
                    oldPoints: oldPoints
                )
            }
            .store(in: &subscribers)
        
        viewModel.horizontalLines
            .sink { [weak self] lines in
                guard let weakSelf = self else { return }
                
                lines.forEach { line in
                    weakSelf.mainLayer.addLineLayer(
                        lineSegment: line.segment,
                        color: UIColor.separator.cgColor,
                        lineWidth: line.width,
                        isDashed: false,
                        animated: false,
                        oldSegment: nil
                    )
                    
                    weakSelf.mainLayer.addTextLayer(
                        frame: CGRect(x: 0, y: line.segment.startPoint.y - 11, width: 30, height: 22),
                        color: UIColor(hex: "#a5afb9")?.cgColor,
                        fontSize: 14,
                        text: "\(line.segment.value)",
                        animated: false,
                        oldFrame: nil
                    )
                }
            }
            .store(in: &subscribers)
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
    
    private func showHorizontalLines(maxValue: Int) {
        layer.sublayers?.forEach {
            if $0 is CAShapeLayer {
                $0.removeFromSuperlayer()
            }
        }
        
        viewModel.generateHorizontalLines(maxValue: maxValue)
    }
    
    private func getControlPoints(for entries: [BarEntry]) -> [CGPoint] {
        guard let firstEntry = entries.first else { return [] }
        
        var points: [CGPoint] = []
        
        entries.forEach {
//            points.append($0.barOrigin)
//            points.append(CGPoint(x: $0.barOrigin.x + $0.barWidth, y: $0.barOrigin.y))
            points.append(CGPoint(x: $0.barOrigin.x + $0.barWidth / 2 ,y: $0.barOrigin.y))
        }
        
        let baseLineY = firstEntry.barOrigin.y + firstEntry.barHeight
        points.insert(CGPoint(x: 40, y: baseLineY), at: 0)
        points.append(CGPoint(x: frame.maxX, y: baseLineY))
        
        return points
    }
}
