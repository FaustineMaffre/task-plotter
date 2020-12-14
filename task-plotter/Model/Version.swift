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
    
    var dueDate: Date? {
        didSet {
            if let dueDate = self.dueDate {
                // set hour to 23h59
                self.dueDate = dueDate.setting(hours: 23, minutes: 59)
            }
        }
    }
    
    var pointsPerDay: Double? {
        didSet {
            // if negative, then nil
            if let pointsPerDay = self.pointsPerDay, pointsPerDay <= 0 {
                self.pointsPerDay = nil
            }
        }
    }
    var workingDays: Set<Day>
    var workingHours: HourInterval
    var excludedDates: Set<Date>
    
    var expectedStartDate: Date? = nil
    
    var tasksByColumn: [Column: [Task]] = Dictionary(uniqueKeysWithValues: Column.allCases.map { ($0, []) })
    
    var ҩtasksByColumnArray: [(Column, [Task])] {
        let columnsOrdered = Dictionary(uniqueKeysWithValues: Column.allCases.enumerated().map { ($0.element, $0.offset) })
        return self.tasksByColumn.sorted { columnsOrdered[$0.key] ?? 0 < columnsOrdered[$1.key] ?? 0 }
    }
    
    init(id: VersionID = UUID(),
         number: String,
         dueDate: Date? = nil,
         pointsPerDay: Double? = nil,
         workingDays: Set<Day> = Day.allDays, workingHours: HourInterval = HourInterval.allHours, excludedDates: Set<Date> = []) {
        self.id = id
        self.number = number
        self.dueDate = dueDate
        self.pointsPerDay = pointsPerDay
        self.workingDays = workingDays
        self.workingHours = workingHours
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
            
        } else if self.workingDays == Day.allDays {
            // all days
            res = "All days"
            
        } else if self.workingDays.isSuperset(of: Day.weekDays) { // .containsAll(other: Day.weekDays) {
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
    
    func formattedExcludedDates(emptyDaysText: String) -> String {
        var res: String
        
        if self.excludedDates.isEmpty {
            res = emptyDaysText
        } else {
            let dateRanges = self.excludedDates.toRangesOfDays()
            
            res = dateRanges
                .map { range in
                    if range.lowerBound.isSameDay(than: range.upperBound) {
                        return Common.excludedDateFormatter.string(from: range.lowerBound)
                        
                    } else {
                        return "\(Common.excludedDateFormatter.string(from: range.lowerBound))-\(Common.excludedDateFormatter.string(from: range.upperBound))"
                    }
                }.joined(separator: ", ")
        }
        
        return res
    }
    
    func canComputeTaskDates() -> Bool {
        self.dueDate != nil && self.pointsPerDay != nil && !self.workingDays.isEmpty
    }
    
    mutating func computeTaskDates() {
        if self.canComputeTaskDates(),
           let dueDate = self.dueDate,
           let pointsPerDay = self.pointsPerDay,
           !self.workingDays.isEmpty {
            let tasksLatestFirst: [(Column, Int)] =
                self.tasksByColumn[.todo]!.indices.reversed().map { (.todo, $0) } +
                self.tasksByColumn[.doing]!.indices.reversed().map { (.doing, $0) }
            
            var costsSum: Double = 0
            
            // tasks due dates
            tasksLatestFirst.forEach { column, taskIndex in
                if let cost = self.tasksByColumn[column]![taskIndex].cost {
                    self.tasksByColumn[column]![taskIndex].expectedDueDate =
                        Self.computeTaskExpectedDueDate(dueDate: dueDate, costsSum: costsSum,
                                                        pointsPerDay: pointsPerDay, workingDays: self.workingDays, workingHours: self.workingHours,
                                                        excludedDates: self.excludedDates)
                    
                    costsSum += cost
                }
            }
            
            // start date
            self.expectedStartDate =
                Self.computeTaskExpectedDueDate(dueDate: dueDate, costsSum: costsSum,
                                                pointsPerDay: pointsPerDay, workingDays: self.workingDays, workingHours: self.workingHours,
                                                excludedDates: self.excludedDates)
        }
    }
    
    private static func computeTaskExpectedDueDate(dueDate: Date, costsSum: Double,
                                                   pointsPerDay: Double, workingDays: Set<Day>, workingHours: HourInterval,
                                                   excludedDates: Set<Date>) -> Date {
        let daysCount = costsSum / pointsPerDay
        let fullDaysCount = Int(daysCount)
        let partialDayRatio = daysCount - Double(fullDaysCount)
        
        var res = dueDate
        
        // substract full days
        (0..<fullDaysCount).forEach { _ in
            res = res.substractingOneDay()
            
            // avoid excluded dates and non-working days
            while excludedDates.contains(where: { res.isSameDay(than: $0) }) || !workingDays.contains(res.day()) {
                res = res.substractingOneDay()
            }
        }
        
        // substract partial day
        let (ratioHours, ratioMinutes) = workingHours.ratio(1 - partialDayRatio)
        res = res.setting(hours: ratioHours, minutes: ratioMinutes)
        
        return res
    }
}
