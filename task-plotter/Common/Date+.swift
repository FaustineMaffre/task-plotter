//
//  Date+.swift
//  task-plotter
//
//  Created by Faustine Maffre on 13/12/2020.
//

import Foundation

extension Date {
    func addingOneDay() -> Date {
        self.addingTimeInterval(24*60*60)
    }
    
    func substractingOneDay() -> Date {
        self.addingTimeInterval(-24*60*60)
    }
    
    func isSameDay(than other: Date) -> Bool {
        Calendar.current.compare(self, to: other, toGranularity: .day) == .orderedSame
    }
    
    func gettingHoursAndMinutes() -> (hours: Int, minutes: Int) {
        let hours = Calendar.current.component(.hour, from: self)
        let minutes = Calendar.current.component(.minute, from: self)
        return (hours, minutes)
    }
    
    func setting(hours: Int, minutes: Int) -> Date {
        Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: self)!
    }
}
