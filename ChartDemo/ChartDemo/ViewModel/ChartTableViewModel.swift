//
//  ChartTableViewModel.swift
//  ChartDemo
//
//  Created by roy on 2022/3/11.
//

import UIKit
import Combine

class ChartTableViewModel: NSObject {
    let dataListSubject = CurrentValueSubject<[ChartData], Never>([])
    
    private weak var tableView: UITableView?
    private lazy var dataSource = makeDataSource()
    private var subscriber: AnyCancellable?
    
    typealias DataSource = UITableViewDiffableDataSource<Section, ChartData>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ChartData>
    typealias ChartData = [DataEntry]
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        setObservation()
    }
}


// MARK: Shared Methods -
extension ChartTableViewModel {
    
    func refreshData(with dataEntries: [ChartData]) {
        dataListSubject.send(dataEntries)
    }
}


// MARK: Private Methods -
extension ChartTableViewModel {
    
    private func setObservation() {
        subscriber = dataListSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
    }
    
    private func makeDataSource() -> DataSource? {
        guard let tableView = tableView else { return nil }
        
        return DataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "BarChartCell",
                for: indexPath
            ) as? BarChartTableViewCell
            cell?.updateInfo(with: item)
            
            return cell
        }
    }
    
    private func applySnapshot(animates: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(dataListSubject.value, toSection: .main)
        
        dataSource?.apply(snapshot, animatingDifferences: animates)
    }
    
    enum Section: Hashable {
        case main
    }
}


// MARK: TableView Delegate
extension ChartTableViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool { false }
}


extension ChartTableViewModel {
    
    func random() -> ChartData {
        var result: ChartData = []
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
        
        return result
    }
}

