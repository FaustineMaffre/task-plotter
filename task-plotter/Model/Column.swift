//
//  Column.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

/// A column containing tasks. Its raw value is its title.
enum Column: String, CaseIterable, Codable {
    case todo = "To do",
         doing = "Doing",
         done = "Done"
    
    /// Returns the binding on the array of task in the given column:
    /// - if the column is nil, returns the tasks pool from the given project;
    /// - if the column is not nil, returns the tasks from this column in the given version.
    static func columnTasksBinding(project: Binding<Project>, version: Binding<Version>, column: Column?) -> Binding<IndexedArray<Task, TaskID>> {
        Binding {
            if let column = column {
                return version.wrappedValue.tasksByColumn[column] ?? IndexedArray(id: \.id)
            } else {
                return project.wrappedValue.tasksPool
            }
        } set: {
            if let column = column {
                version.wrappedValue.tasksByColumn[column] = $0
            } else {
                project.wrappedValue.tasksPool = $0
            }
        }
    }
}
