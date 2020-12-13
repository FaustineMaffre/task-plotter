//
//  Day.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

enum Day: String, CaseIterable {
    case monday = "Monday",
         tuesday = "Tuesday",
         wednesday = "Wednesday",
         thursday = "Thursday",
         friday = "Friday",
         saturday = "Saturday",
         sunday = "Sunday"
    
    static let weekDays: [Day] = [.monday, .tuesday, .wednesday, .thursday, .friday]
    
    var ҩlongName: String {
        self.rawValue
    }
    
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
