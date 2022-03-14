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

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setObservation()
    }
}


// MARK: Shared Methods -
extension BarChartTableViewCell {
    
    func updateInfo(with dataEntries: [DataEntry]) {
        barChartView.dataEntries = dataEntries
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
}
