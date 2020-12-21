//
//  Day.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

/// A working day in the week.
enum Day: String, CaseIterable, Codable {
    case monday = "Monday",
         tuesday = "Tuesday",
         wednesday = "Wednesday",
         thursday = "Thursday",
         friday = "Friday",
         saturday = "Saturday",
         sunday = "Sunday"
    
    static let allDays: Set<Day> = Set(Day.allCases)
    static let weekDays: Set<Day> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    
    /// Full name of the day (with first letter capitalized).
    var ҩlongName: String {
        self.rawValue
    }
    
    /// Name of the day on three characters (with first letter capitalized), followed by a dot.
    var ҩshortName: String {
        switch self {
        case .monday: return "Mon."
        case .tuesday: return "Tue."
        case .wednesday: return "Wed."
        case .thursday: return "Thu."
        case .friday: return "Fri."
        case .saturday: return "Sat."
        case .sunday: return "Sun."
        }
    }
}

extension Date {
    /// Returns the day (of the week) of this date. 
    func day() -> Day {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return Day(rawValue: dateFormatter.string(from: self))!
    }
}
