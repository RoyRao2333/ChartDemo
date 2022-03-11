//
//  ViewController.swift
//  ChartDemo
//
//  Created by roy on 2022/3/7.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var tableViewModel = ChartTableViewModel(tableView: tableView)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = tableViewModel
    }
}


extension ViewController {
    
    
}
