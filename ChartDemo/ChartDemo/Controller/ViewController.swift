//
//  ViewController.swift
//  ChartDemo
//
//  Created by roy on 2022/3/7.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet private weak var barChatView: BarChartView!
    @IBOutlet private var generateBtn: UIButton!
    @IBOutlet private var countLabel: UILabel!
    
    private var subscriber: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        subscriber = NotificationCenter.default
            .publisher(for: .tapChanged, object: nil)
            .compactMap { $0.userInfo as? [String: String] }
            .compactMap { $0["count"] }
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: countLabel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dataEntries: [DataEntry] = Array(
            repeating: DataEntry(value: 0, date: "", barColor: .clear, barHeightPer: 0),
            count: barChatView.barCount
        )
        
        barChatView.updateEntries(with: dataEntries)
    }
}


extension ViewController {
    
    @IBAction private func generateRandomDataEntries(_ sender: UIButton) {
        barChatView.random()
        countLabel.text = "N/A"
    }
}
