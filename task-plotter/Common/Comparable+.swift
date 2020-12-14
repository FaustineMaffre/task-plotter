//
//  Int+.swift
//  task-plotter
//
//  Created by Faustine Maffre on 14/12/2020.
//

import Foundation

extension Comparable {
    func clampBetween(_ minValue: Self, and maxValue: Self) -> Self {
        Swift.min(maxValue, Swift.max(minValue, self))
    }
}
