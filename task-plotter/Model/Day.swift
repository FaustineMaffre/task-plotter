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
    
    static let all: [Day] = Self.allCases
    static let week: [Day] = [.monday, .tuesday, .wednesday, .thursday, .friday]
}
