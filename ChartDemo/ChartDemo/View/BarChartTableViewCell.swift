//
//  BarChartTableViewCell.swift
//  ChartDemo
//
//  Created by roy on 2022/3/10.
//

import UIKit
import Combine

class BarChartTableViewCell: UITableViewCell {
    @IBOutlet private weak var barChatView: BarChartView!
    @IBOutlet private var countLabel: UILabel!
    
    private var subscribers: Set<AnyCancellable> = []

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        
        NotificationCenter.default
            .publisher(for: .tapChanged, object: nil)
            .compactMap { $0.userInfo as? [String: String] }
            .compactMap { $0["count"] }
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: countLabel)
            .store(in: &subscribers)
        
        Timer.publish(every: 5, on: .main, in: .common)
            .sink { [weak self] _ in
                self?.barChatView.random()
                self?.countLabel.text = "N/A"
            }
            .store(in: &subscribers)
    }
}


extension BarChartTableViewCell {
    
    private func setup() {
        let dataEntries: [DataEntry] = Array(
            repeating: DataEntry(value: 0, date: "", barColor: .clear, barHeightPer: 0),
            count: barChatView.barCount
        )
        
        barChatView.updateEntries(with: dataEntries)
    }
}
