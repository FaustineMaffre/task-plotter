//
//  HourInterval.swift
//  task-plotter
//
//  Created by Faustine Maffre on 13/12/2020.
//

import Foundation

/// A basic interval of hours of a day (without minutes).
struct HourInterval: Codable {
    /// Start hour, between `0` and `endHour - 1`.
    var startHour: Int {
        didSet {
            self.startHour = self.startHour.clampBetween(0, and: self.endHour - 1)
        }
    }
    
    /// End hour, between `startHour + 1` and `23`.
    var endHour: Int {
        didSet {
            self.endHour = self.endHour.clampBetween(self.startHour + 1, and: 23)
        }
    }
    
    /// The interval containing all hours (from 0 to 23) of the day.
    static let allHours: HourInterval = HourInterval(startHour: 0, endHour: 23)
    
    /// Returns the hours and minutes corresponding to the given ratio of the day.
    ///
    /// If hours = [9-18], then:
    /// - a ratio of 0 gives (9, 0);
    /// - a ratio of 1 gives (18, 0);
    /// - a ratio of 0.5 gives (13, 30).
    ///
    /// Ratios not between 0 and 1 will give undetermined results (probably hours outside the interval).
    func ratioToHours(_ ratio: Double) -> (hours: Int, minutes: Int) {
        let decimalRes = ratio * Double(self.endHour - self.startHour) + Double(self.startHour)
        let hours = Int(decimalRes)
        let minutes = Int(60 * (decimalRes - Double(hours)))
        return (hours, minutes)
    }
    
    /// Returns the ratio corresponding to the **remaining hours in the day** after the given hours and minutes.
    ///
    /// If hours = [9-18], then:
    /// - (9, 0) gives 1;
    /// - (18, 0) gives 0;
    /// - (10, 0) gives 0.888....
    ///
    /// The ratio is clamped between 0 and 1, so even if the given hours and minutes are outside the hours interval,
    /// the method will return a value between 0 and 1.
    func remainingHoursToRatio(hours: Int, minutes: Int) -> Double {
        let decimalHours = Double(hours) + Double(minutes) / 60
        let res = (Double(self.endHour) - decimalHours) / Double(self.endHour - self.startHour)
        
        // clamp between 0 (if after endHour) and 1 (if before startHour)
        return res.clampBetween(0, and: 1)
    }
}
