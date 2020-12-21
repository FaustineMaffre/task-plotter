//
//  Version.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias VersionID = UUID

/// A version of a project, containing tasks and to which can be assigned points per day and working days/hours along
/// with a due date to compute its tasks due date.
struct Version: Identifiable, Hashable, Equatable, Codable {
    
    let id: VersionID
    
    /// "Number" of this version, that can actually be any string.
    var number: String
    
    /// Number of cost points done per day, if it is given.
    ///
    /// Put to nil if set to a negative value.
    var pointsPerDay: Double? {
        didSet {
            if let pointsPerDay = self.pointsPerDay, pointsPerDay <= 0 {
                self.pointsPerDay = nil
            }
        }
    }
    
    /// Normal working days for this version.
    var workingDays: Set<Day>
    /// Normal working hours for this version.
    var workingHours: HourInterval
    /// Dates that may normally be worked, but are excluded (e.g. 25 Dec).
    var excludedDates: Set<Date>
    
    /// Due date of this version, if given.
    ///
    /// Only the day should be given, as the hour is automatically set to 23h59.
    var dueDate: Date? {
        didSet {
            if let dueDate = self.dueDate {
                // set hour to 23h59
                self.dueDate = dueDate.setting(hours: 23, minutes: 59)
            }
        }
    }
    
    /// Sum of points of to do/doing tasks currently added to this version, or nil if there is none.
    var ҩpointsOngoing: Double? {
        self.computePointsOngoing()
    }
    
    /// Remaining points until the due date if we start now, if there are points per day, working days, due date and
    /// the version is not validated.
    var ҩpointsStartingNow: Double? {
        self.computePointsStartingNow()
    }
    
    /// Expected start date, that is, due date of the first task to do minus its estimation.
    ///
    /// Not given, but updated along with tasks dates.
    var expectedStartDate: Date? = nil
    
    /// True if this version was validated by the user.
    var isValidated: Bool = false
    
    /// Tasks in this version, organized by columns.
    var tasksByColumn: [Column: IndexedArray<Task, TaskID>] = Dictionary(uniqueKeysWithValues: Column.allCases.map { ($0, IndexedArray(id: \.id)) })
    
    /// Tasks in this version, organized by columns, sorted in the order of columns.
    var ҩtasksByColumnArray: [(Column, IndexedArray<Task, TaskID>)] {
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
    
    /// Formats the working days of this version to a string.
    ///
    /// If `workingDays` is empty, returns "None";
    /// if it contains all days, returns "All days";
    /// if it contains Monday to Friday, returns "Week days";
    /// otherwise returns the list of short names of days.
    func formattedWorkingDays() -> String {
        var res: String
        
        if self.workingDays.isEmpty {
            // no days
            res = "None"
            
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
    
    /// Formats excluded dates of this version to a string.
    func formattedExcludedDates() -> String {
        var res: String
        
        if self.excludedDates.isEmpty {
            res = "None"
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
        let ongoingTasks = (self.tasksByColumn[.todo]?.elements ?? []) + (self.tasksByColumn[.doing]?.elements ?? [])
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
        res += self.workingHours.remainingHoursToRatio(hours: nowHours, minutes: nowMinutes) * pointsPerDay
        
        return res
    }
    
    /// True if tasks due dates can be computed (i.e. there are points per day, working days, a due date and the
    /// version is not validated).
    func canComputeTaskDates() -> Bool {
        self.pointsPerDay != nil && !self.workingDays.isEmpty && self.dueDate != nil && !self.isValidated
    }
    
    /// Computes due dates of tasks of this version (and the expected start date) if possible.
    mutating func computeTaskDates() {
        if self.canComputeTaskDates(),
           let pointsPerDay = self.pointsPerDay,
           !self.workingDays.isEmpty,
           let dueDate = self.dueDate {
            let tasksLatestFirst: [(Column, Int)] =
                (self.tasksByColumn[.todo]?.elements ?? []).indices.reversed().map { (.todo, $0) } +
                (self.tasksByColumn[.doing]?.elements ?? []).indices.reversed().map { (.doing, $0) }
            
            var costsSum: Double = 0
            
            // tasks due dates
            tasksLatestFirst.forEach { column, taskIndex in
                if let cost = self.tasksByColumn[column]?[taskIndex].cost {
                    self.tasksByColumn[column]?[taskIndex].expectedDueDate =
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
    
    /// Computes the expected due date of a task, given the version's due date and the sum of costs between the task
    /// and this due date.
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
    
    /// Computes the working date at least one day before the given date, given the working days and excluded dates.
    ///
    /// Assumes there are working days.
    static func previousWorkedDay(date: Date, workingDays: Set<Day>, excludedDates: Set<Date>) -> Date {
        var res = date
        
        repeat {
            res = res.substractingOneDay()
        } while excludedDates.contains(where: { res.isSameDay(than: $0) }) || !workingDays.contains(res.day())
        
        return res
    }
    
    /// Computes the working date at least one day after the given date, given the working days and excluded dates.
    ///
    /// Assumes there are working days.
    static func nextWorkedDay(date: Date, workingDays: Set<Day>, excludedDates: Set<Date>) -> Date {
        var res = date
        
        repeat {
            res = res.addingOneDay()
        } while excludedDates.contains(where: { res.isSameDay(than: $0) }) || !workingDays.contains(res.day())
        
        return res
    }
    
    /// True if due dates of tasks of this version can be cleared (i.e. the version is not validated).
    func canClearTaskDates() -> Bool {
        !self.isValidated
    }
    
    /// Clears due dates of tasks of this version, if possible.
    mutating func clearTaskDates() {
        if self.canClearTaskDates() {
            (self.tasksByColumn[.todo]?.elements ?? []).indices.forEach {
                self.tasksByColumn[.todo]?[$0].expectedDueDate = nil
            }
            
            (self.tasksByColumn[.doing]?.elements ?? []).indices.forEach {
                self.tasksByColumn[.doing]?[$0].expectedDueDate = nil
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
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case id,
             number,
             pointsPerDay, workingDays, workingHours, excludedDates,
             dueDate,
             expectedStartDate, isValidated,
             tasksByColumn
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(VersionID.self, forKey: .id)
        let number = try container.decode(String.self, forKey: .number)
        let pointsPerDay = try container.decode(Double?.self, forKey: .pointsPerDay)
        let workingDays = try container.decode(Set<Day>.self, forKey: .workingDays)
        let workingHours = try container.decode(HourInterval.self, forKey: .workingHours)
        let excludedDates = try container.decode(Set<Date>.self, forKey: .excludedDates)
        let dueDate = try container.decode(Date?.self, forKey: .dueDate)
        let expectedStartDate = try container.decode(Date?.self, forKey: .expectedStartDate)
        let isValidated = try container.decode(Bool.self, forKey: .isValidated)
        let tasksByColumn = try container.decode([Column: [Task]].self, forKey: .tasksByColumn)
        
        self.init(id: id, number: number,
                  pointsPerDay: pointsPerDay, workingDays: workingDays, workingHours: workingHours, excludedDates: excludedDates,
                  dueDate: dueDate)
        self.expectedStartDate = expectedStartDate
        self.isValidated = isValidated
        self.tasksByColumn = Dictionary(uniqueKeysWithValues: tasksByColumn.map { ($0.key, IndexedArray(elements: $0.value, id: \.id)) })
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.number, forKey: .number)
        try container.encode(self.pointsPerDay, forKey: .pointsPerDay)
        try container.encode(self.workingDays, forKey: .workingDays)
        try container.encode(self.workingHours, forKey: .workingHours)
        try container.encode(self.excludedDates, forKey: .excludedDates)
        try container.encode(self.dueDate, forKey: .dueDate)
        try container.encode(self.expectedStartDate, forKey: .expectedStartDate)
        try container.encode(self.isValidated, forKey: .isValidated)
        let tasksByColumn = Dictionary(uniqueKeysWithValues: self.tasksByColumn.map { ($0.key, $0.value.elements) })
        try container.encode(tasksByColumn, forKey: .tasksByColumn)
    }
}
