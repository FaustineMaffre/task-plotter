//
//  Column.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

enum Column: String, CaseIterable, Codable {
    case todo = "To do",
         doing = "Doing",
         done = "Done"
    
    static func columnTasksBinding(project: Binding<Project>, version: Binding<Version>,
                            column: Column?) -> Binding<[Task]> {
        Binding<[Task]> {
            if let column = column {
                return version.wrappedValue.tasksByColumn[column]!
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
