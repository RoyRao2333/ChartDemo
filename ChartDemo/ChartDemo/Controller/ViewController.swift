//
//  ViewController.swift
//  ChartDemo
//
//  Created by roy on 2022/3/7.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private var generateBtn: UIButton!
    
    private lazy var dataSource = makeDataSource()
    private var models: [BarEntry] = []
    
    typealias DataSource = UITableViewDiffableDataSource<Section, BarEntry>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, BarEntry>

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
    }
}


extension ViewController {
    
    private func makeDataSource() -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "BarChartCell",
                for: indexPath
            ) as? BarChartTableViewCell
            
            return cell
        }
    }
    
    private func applySnapshot(animates: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(models, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: animates)
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
        
        
    }
}


extension ViewController: UITableViewDelegate {
    
}


extension ViewController {
    
    enum Section: Hashable {
        case main
    }
}
