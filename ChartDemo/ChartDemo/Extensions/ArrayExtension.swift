//
//  ArrayExtension.swift
//  BarChart
//
//  Created by Nguyen Vu Nhat Minh on 2/6/19.
//  Copyright © 2019 Nguyen Vu Nhat Minh. All rights reserved.
//

import Foundation

extension Array {
    
    func safeValue(at index: Int) -> Element? {
        if (0 ..< count).contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
}
