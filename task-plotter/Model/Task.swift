//
//  Task.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias TaskID = UUID

/// A task that can be placed in the tasks pool or in a column of a version.
struct Task: Identifiable, Hashable, Equatable, Codable {
    
    let id: TaskID
    
    var title: String
    var description: String
    
    /// Project labels assigned to this task.
    var labelIds: [LabelID]
    
    /// Expected cost of this task, if it is given.
    ///
    /// Put to nil if set to a negative value.
    var cost: Double? {
        didSet {
            if let cost = self.cost, cost <= 0 {
                self.cost = nil
            }
        }
    }
    
    /// Due date, computed from the version due date and parameters (not set directly by the user). 
    var expectedDueDate: Date? = nil
    
    init(id: TaskID = UUID(),
         title: String, labelIds: [LabelID] = [], description: String = "",
         cost: Double? = nil) {
        self.id = id
        self.title = title
        self.labelIds = labelIds
        self.description = description
        self.cost = cost
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
}
