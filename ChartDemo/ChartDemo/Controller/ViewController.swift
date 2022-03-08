//
//  ViewController.swift
//  ChartDemo
//
//  Created by roy on 2022/3/7.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var barChatView: BarChartView!
    @IBOutlet private var generateBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    }
}
