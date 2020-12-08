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
    
    var ҩtaskByColumn: [(column: Column, tasks: [Task])] {
        // create an array for each column, even if it is going to be empty
        var res = Column.allCases.map { (column: $0, tasks: [Task]()) }
        
        // index of each column to find it quicker
        let columnsOrdered = Dictionary(uniqueKeysWithValues: res.enumerated().map { ($0.element.0, $0.offset) })
        
        self.tasks.forEach {
            if let columnIndex = columnsOrdered[$0.column] {
                res[columnIndex].tasks.append($0)
            }
        }
        
        return res
    }
    
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
    
    mutating func addTask(column: Column, title: String) {
        if !title.isEmpty {
            // create new task
            let newTask = Task(column: column, title: title)
            self.tasks.append(newTask)
        }
    }
    
    mutating func deleteTask(task: Task) {
        if let taskIndex = self.tasks.firstIndex(of: task) {
            self.tasks.remove(at: taskIndex)
        }
    }
}
