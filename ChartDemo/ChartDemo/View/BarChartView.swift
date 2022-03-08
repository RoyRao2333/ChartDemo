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
    private let scrollView = UIScrollView()
    
    private var subscribers: Set<AnyCancellable> = []
    private let viewModel = BarChartViewModel(barWidth: 40, barSpacing: 20)
    
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
}


extension BarChartView {
    
    func updateEntries(with dataEntries: [DataEntry]) {
        viewModel.generateBarEntries(dataEntries: dataEntries, contentHeight: frame.height)
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
        scrollView.layer.addSublayer(mainLayer)
        addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func setObservation() {
        viewModel.barEntries
            .withPrevious()
            .sink { [weak self] output in
                guard let weakSelf = self else { return }
                
                weakSelf.mainLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
                weakSelf.scrollView.contentSize = CGSize(
                    width: weakSelf.viewModel.chartViewContentWidth,
                    height: weakSelf.frame.size.height
                )
                weakSelf.mainLayer.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: weakSelf.scrollView.contentSize.width,
                    height: weakSelf.scrollView.contentSize.height
                )
                
                let values = output.current.map({ $0.data.value })
                if !values.isEmpty {
                    let max = values.max() ?? values.first!
                    weakSelf.showHorizontalLines(maxValue: max)
                }
                
                for (index, entry) in output.current.enumerated() {
                    let oldValue = output.previous?.safeValue(at: index)
                    weakSelf.addBar(index: index, entry: entry, oldEntry: oldValue)
                }
            }
            .store(in: &subscribers)
        
        viewModel.horizontalLines
            .sink { [weak self] lines in
                guard let weakSelf = self else { return }
                
                lines.forEach { line in
                    weakSelf.mainLayer.addLineLayer(
                        lineSegment: line.segment,
                        color: UIColor.separator.cgColor,
                        width: line.width,
                        isDashed: false,
                        animated: false,
                        oldSegment: nil
                    )
                }
            }
            .store(in: &subscribers)
    }
    
    private func addBar(index: Int, entry: BarEntry, oldEntry: BarEntry? = nil, animated: Bool = true) {
        let barColor = entry.data.barColor.cgColor
        
        mainLayer.addRectangleLayer(
            frame: entry.barFrame,
            color: barColor,
            animated: animated,
            oldFrame: oldEntry?.barFrame
        )
        
        mainLayer.addTextLayer(
            frame: entry.dateLabelFrame,
            color: barColor,
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
        
        viewModel.generateHorizontalLines(maxValue: maxValue, contentHeight: frame.height)
    }
}
