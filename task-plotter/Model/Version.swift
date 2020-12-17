//
//  Version.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias VersionID = UUID

struct Version: Identifiable, Hashable, Equatable, Codable {
    
    let id: VersionID
    
    var number: String
    
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
    
    var dueDate: Date? {
        didSet {
            if let dueDate = self.dueDate {
                // set hour to 23h59
                self.dueDate = dueDate.setting(hours: 23, minutes: 59)
            }
        }
    }
    
    var pointsOngoing: Double? {
        self.computePointsOngoing()
    }
    
    var pointsStartingNow: Double? {
        self.computePointsStartingNow()
    }
    
    var expectedStartDate: Date? = nil
    var isValidated: Bool = false
    
    var tasksByColumn: [Column: [Task]] = Dictionary(uniqueKeysWithValues: Column.allCases.map { ($0, []) })
    
    var ҩtasksByColumnArray: [(Column, [Task])] {
        let columnsOrdered = Dictionary(uniqueKeysWithValues: Column.allCases.enumerated().map { ($0.element, $0.offset) })
        return self.tasksByColumn.sorted { columnsOrdered[$0.key] ?? 0 < columnsOrdered[$1.key] ?? 0 }
    }
    
    init(id: VersionID = UUID(),
         number: String,
         pointsPerDay: Double? = nil,
         workingDays: Set<Day> = Day.allDays, workingHours: HourInterval = HourInterval.allHours, excludedDates: Set<Date> = [],
         dueDate: Date? = nil) {
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
    
    func computePointsOngoing() -> Double? {
        let ongoingTasks = self.tasksByColumn[.todo]! + self.tasksByColumn[.doing]!
        let res = ongoingTasks.compactMap(\.cost).reduce(0, +) // sum
        return res <= 0 ? nil : res
    }
    
    func computePointsStartingNow() -> Double? {
        let now = Date()
        
        guard let pointsPerDay = self.pointsPerDay,
              !self.workingDays.isEmpty,
              let dueDate = self.dueDate,
              dueDate > now,
              !self.isValidated else {
            return nil
        }
        
        var currentDate = dueDate
        var res: Double = 0
        
        // full days
        while !currentDate.isSameDay(than: now) {
            // count non-excluded dates and working days only
            if !self.excludedDates.contains(where: { currentDate.isSameDay(than: $0) }) && self.workingDays.contains(currentDate.day()) {
                res += pointsPerDay
            }
            
            currentDate = currentDate.substractingOneDay()
        }
        
        // partial day
        let (nowHours, nowMinutes) = now.gettingHoursAndMinutes()
        res += self.workingHours.hoursToRatio(hours: nowHours, minutes: nowMinutes) * pointsPerDay
        
        return res
    }
    
    func canComputeTaskDates() -> Bool {
        self.pointsPerDay != nil && !self.workingDays.isEmpty && self.dueDate != nil && !self.isValidated
    }
    
    mutating func computeTaskDates() {
        if self.canComputeTaskDates(),
           let pointsPerDay = self.pointsPerDay,
           !self.workingDays.isEmpty,
           let dueDate = self.dueDate {
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
            var startDate = Self.computeTaskExpectedDueDate(dueDate: dueDate, costsSum: costsSum,
                                                            pointsPerDay: pointsPerDay, workingDays: self.workingDays, workingHours: self.workingHours,
                                                            excludedDates: self.excludedDates)
            
            if startDate.gettingHoursAndMinutes().hours == self.workingHours.endHour {
                // if start date is at the end of a day, set it to the start of the next day
                startDate = Self.nextWorkedDay(date: startDate, workingDays: self.workingDays, excludedDates: self.excludedDates)
                startDate = startDate.setting(hours: self.workingHours.startHour, minutes: 0)
            }
            
            self.expectedStartDate = startDate
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
            res = Self.previousWorkedDay(date: res, workingDays: workingDays, excludedDates: excludedDates)
        }
        
        // substract partial day
        let (ratioHours, ratioMinutes) = workingHours.ratioToHours(1 - partialDayRatio)
        res = res.setting(hours: ratioHours, minutes: ratioMinutes)
        
        return res
    }
    
    static func previousWorkedDay(date: Date, workingDays: Set<Day>, excludedDates: Set<Date>) -> Date {
        var res = date
        
        repeat {
            res = res.substractingOneDay()
        } while excludedDates.contains(where: { res.isSameDay(than: $0) }) || !workingDays.contains(res.day())
        
        return res
    }
    
    static func nextWorkedDay(date: Date, workingDays: Set<Day>, excludedDates: Set<Date>) -> Date {
        var res = date
        
        // avoid excluded dates and non-working days
        // (assumes there are working days)
        repeat {
            res = res.addingOneDay()
        } while excludedDates.contains(where: { res.isSameDay(than: $0) }) || !workingDays.contains(res.day())
        
        return res
    }
    
    func canClearTaskDates() -> Bool {
        !self.isValidated
    }
    
    mutating func clearTaskDates() {
        if self.canClearTaskDates() {
            self.tasksByColumn[.todo]!.indices.forEach {
                self.tasksByColumn[.todo]![$0].expectedDueDate = nil
            }
            
            self.tasksByColumn[.doing]!.indices.forEach {
                self.tasksByColumn[.doing]![$0].expectedDueDate = nil
            }
            
            // start date
            self.expectedStartDate = nil
        }
    }
    
    mutating func validate() {
        // TODOlt stats for the version?
        self.isValidated = true
    }
    
    mutating func invalidate() {
        self.isValidated = false
    }
}
