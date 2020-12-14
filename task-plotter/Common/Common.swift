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
    
    static let pointsPerDayFormatter: NumberFormatter = {
        var res = NumberFormatter()
        res.numberStyle = .decimal
        return res
    }()
    
    static let workingHourFormatter: NumberFormatter = {
        var res = NumberFormatter()
        res.numberStyle = .none
        return res
    }()
    
    static let excludedDateFormatter: DateFormatter = {
        var res = DateFormatter()
        res.dateFormat = "dd MMM"
        return res
    }()
    
    static let dueDateFormatter: DateFormatter = {
        var res = DateFormatter()
        res.dateStyle = .medium
        res.timeStyle = .none
        return res
    }()
}
