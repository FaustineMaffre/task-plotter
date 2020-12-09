//
//  TasksView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

// TODO delete task
// TODO move task

// TODO due date
// TODO points per day, working days, excluded dates
// TODO compute dates per task 

struct TasksView: View {
    @Binding var version: Version
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tasks")
                    .titleStyle()
                    .padding(10)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(self.version.ҩtaskIndicesByColumn, id: \.0) { column, tasksIndices in
                    VStack(spacing: 0) {
                        HStack {
                            Text(column.rawValue)
                                .smallTitleStyle()
                                .padding(10)
                            
                            Spacer()
                        }
                        
                        ScrollView {
                            VStack(spacing: 4) {
                                ForEach(tasksIndices, id: \.self) { taskIndex in
                                    TaskView(task: self.generateTaskBinding(taskIndex: taskIndex))
                                }
                                
                                HStack {
                                    CreateTaskButton(version: self.$version, column: column, showText: true)
                                    Spacer()
                                }
                            }
                        }
                        .padding(10)
                    }
                    .frame(width: 300)
                    .background(RoundedRectangle(cornerRadius: 8)
                                    .fillAndStroke(fill: Color(NSColor.underPageBackgroundColor),
                                                   stroke: Color.white.opacity(0.1)))
                }
            }
            .padding(10)
        }
    }
    
    func generateTaskBinding(taskIndex: Int) -> Binding<Task> {
        Binding {
            self.version.tasks[taskIndex]
        } set: {
            self.version.tasks[taskIndex] = $0
        }
    }
}

