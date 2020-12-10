//
//  Task.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias TaskID = UUID

struct Task: Identifiable, Hashable, Equatable {
    
    let id: TaskID
    
    var title: String
    var labels: [Label]
    var description: String
    
    var cost: Float?
    
    var expectedDueDate: Date? = nil
    
    init(id: TaskID = UUID(),
         title: String, labels: [Label] = [], description: String = "",
         cost: Float? = nil) {
        self.id = id
        self.title = title
        self.labels = labels
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
