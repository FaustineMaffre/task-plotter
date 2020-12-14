//
//  Hour.swift
//  task-plotter
//
//  Created by Faustine Maffre on 13/12/2020.
//

import Foundation

struct HourInterval {
    var startHour: Int {
        didSet {
            self.startHour = self.startHour.clampBetween(0, and: self.endHour - 1)
        }
    }
    var endHour: Int {
        didSet {
            self.endHour = self.endHour.clampBetween(self.startHour + 1, and: 23)
        }
    }
    
    static let allHours: HourInterval = HourInterval(startHour: 0, endHour: 23)
    
    func ratio(_ ratio: Double) -> (hours: Int, minutes: Int) {
        let decimalRes = ratio * Double(self.endHour - self.startHour) + Double(self.startHour)
        let hours = Int(decimalRes)
        let minutes = Int(60 * (decimalRes - Double(hours)))
        return (hours, minutes)
    }
}
