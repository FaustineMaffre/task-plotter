//
//  Common.swift
//  task-plotter
//
//  Created by Faustine Maffre on 09/12/2020.
//

import Foundation

class Common {
    static let costFormatter: NumberFormatter = {
        var res = NumberFormatter()
        res.numberStyle = .decimal
        return res
    }()
}
