//
//  ChartTableViewModel.swift
//  ChartDemo
//
//  Created by roy on 2022/3/11.
//

import UIKit
import Combine

class ChartTableViewModel: NSObject {
    private weak var tableView: UITableView?
    private lazy var dataSource = makeDataSource()
    let chartListSubject = CurrentValueSubject<[BarEntries], Never>([])
    private var subscribers: Set<AnyCancellable> = []
    
    typealias DataSource = UITableViewDiffableDataSource<Section, BarEntries>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, BarEntries>
    typealias BarEntries = [BarEntry]
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        setObservation()
    }
}


extension ChartTableViewModel {
    
    private func setObservation() {
        chartListSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applySnapshot()
            }
            .store(in: &subscribers)
        
        chartListSubject
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
        snapshot.appendItems(chartListSubject.value, toSection: .main)
        
        dataSource?.apply(snapshot, animatingDifferences: animates)
    }
    
    
}


extension ChartTableViewModel: UITableViewDelegate {
    
}


extension ChartTableViewModel {
    
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
    
    enum Section: Hashable {
        case main
    }
}

