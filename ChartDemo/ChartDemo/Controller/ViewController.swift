//
//  ViewController.swift
//  ChartDemo
//
//  Created by roy on 2022/3/7.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var viewModel = ChartTableViewModel(tableView: tableView)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
}


extension ViewController {
    
    private func setup() {
        tableView.delegate = viewModel
        
        viewModel.refreshData(with: [
            viewModel.random(),
            viewModel.random(),
            viewModel.random(),
            viewModel.random(),
        ])
    }
}
