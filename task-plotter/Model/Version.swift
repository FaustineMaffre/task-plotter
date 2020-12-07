//
//  Version.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias VersionID = UUID

struct Version: Identifiable, Hashable, Equatable {
    let id: VersionID
    
    var number: String
    
    var dueDate: Date?
    
    var pointsPerDay: Float?
    var workingDays: [Day]
    var excludedDates: [Date]
    
    var tasks: [Task] = []
    
    init(id: VersionID = UUID(),
         number: String,
         dueDate: Date? = nil,
         pointsPerDay: Float? = nil, workingDays: [Day] = Day.all, excludedDates: [Date] = []) {
        self.id = id
        self.number = number
        self.dueDate = dueDate
        self.pointsPerDay = pointsPerDay
        self.workingDays = workingDays
        self.excludedDates = excludedDates
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Version, rhs: Version) -> Bool {
        lhs.id == rhs.id
    }
}
