//
//  Task.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias TaskID = UUID

struct Task: Identifiable {
    let id: TaskID
    
    var column: Column
    
    var title: String
    var labels: [Label]
    var description: String
    
    var cost: Float?
    
    var expectedDueDate: Date? = nil
    
    init(id: TaskID = UUID(),
         column: Column,
         title: String, labels: [Label] = [], description: String = "",
         cost: Float? = nil) {
        self.id = id
        self.column = column
        self.title = title
        self.labels = labels
        self.description = description
        self.cost = cost
    }
}
