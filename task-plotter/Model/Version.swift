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
    
    var pointsPerDay: Double? {
        didSet {
            // if negative, then nil
            if let pointsPerDay = self.pointsPerDay, pointsPerDay <= 0 {
                self.pointsPerDay = nil
            }
        }
    }
    var workingDays: [Day]
    var excludedDates: [Date]
    
    var tasksByColumn: [Column: [Task]] = Dictionary(uniqueKeysWithValues: Column.allCases.map { ($0, []) })
    
    var ҩtasksByColumnArray: [(Column, [Task])] {
        let columnsOrdered = Dictionary(uniqueKeysWithValues: Column.allCases.enumerated().map { ($0.element, $0.offset) })
        return self.tasksByColumn.sorted { columnsOrdered[$0.key] ?? 0 < columnsOrdered[$1.key] ?? 0 }
    }
    
    init(id: VersionID = UUID(),
         number: String,
         dueDate: Date? = nil,
         pointsPerDay: Double? = nil, workingDays: [Day] = Day.allCases, excludedDates: [Date] = []) {
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
    
    func getTask(column: Column, taskIndex: Int) -> Task {
        self.tasksByColumn[column]![taskIndex]
    }
    
    mutating func addTask(column: Column, _ task: Task) {
        if !task.title.isEmpty {
            self.tasksByColumn[column]!.append(task)
        }
    }
    
    mutating func deleteTask(column: Column, task: Task) {
        self.tasksByColumn[column]!.remove(task)
    }
    
    func findColumnOfTask(id: TaskID) -> Column? {
        self.tasksByColumn.first { _, tasks in
            tasks.contains { $0.id == id }
        }?.key
    }
    
    func formattedWorkingDays(emptyDaysText: String) -> String {
        var res: String
        
        if self.workingDays.isEmpty {
            // no days
            res = emptyDaysText
            
        } else if self.workingDays.containsAll(other: Day.allCases) {
            // all days
            res = "All days"
            
        } else if self.workingDays.containsAll(other: Day.weekDays) {
            // all week days
            res = "Week days"
            
            // + saturday or sunday (not both, otherwise we were in the first case)
            if self.workingDays.contains(Day.saturday) {
                res += " + \(Day.saturday.ҩshortName)"
            } else if self.workingDays.contains(Day.sunday) {
                res += " + \(Day.sunday.ҩshortName)"
            }
        } else {
            // all days, separately
            res = Day.allCases
                .filter { self.workingDays.contains($0) }
                .map { $0.ҩshortName }
                .joined(separator: ", ")
        }
        
        return res
    }
}
