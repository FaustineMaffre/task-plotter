//
//  HourInterval.swift
//  task-plotter
//
//  Created by Faustine Maffre on 13/12/2020.
//

import Foundation

struct HourInterval: Codable {
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
    
    func ratioToHours(_ ratio: Double) -> (hours: Int, minutes: Int) {
        let decimalRes = ratio * Double(self.endHour - self.startHour) + Double(self.startHour)
        let hours = Int(decimalRes)
        let minutes = Int(60 * (decimalRes - Double(hours)))
        return (hours, minutes)
    }
    
    func hoursToRatio(hours: Int, minutes: Int) -> Double {
        let decimalHours = Double(hours) + Double(minutes) / 60
        let res = (Double(self.endHour) - decimalHours) / Double(self.endHour - self.startHour)
        
        // clamp between 0 (if after endHour) and 1 (if before startHour)
        return res.clampBetween(0, and: 1)
    }
}
