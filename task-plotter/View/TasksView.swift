//
//  TasksView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct TasksView: View {
    @ObservedObject var repository: Repository
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tasks")
                    .titleStyle()
                    .padding(10)
                
                Spacer()
            }
            
            if let selectedVersion = self.repository.ҩselectedProject?.ҩselectedVersion {
                HStack(spacing: 8) {
                    ForEach(selectedVersion.ҩtaskByColumn, id: \.0) { column, tasks in
                        VStack(spacing: 0) {
                            HStack {
                                Text(column.rawValue)
                                    .smallTitleStyle()
                                    .padding(10)
                                
                                Spacer()
                            }
                            
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(tasks) { task in
                                        TaskView(task: task)
                                    }
                                    
                                    HStack {
                                        CreateTaskButton(repository: self.repository, column: column, showText: true)
                                        Spacer()
                                    }
                                }
                            }
                            .padding(10)
                        }
                        .frame(width: 300)
                        .background(RoundedRectangle(cornerRadius: 8)
                                        .fillAndStroke(fill: Color(NSColor.underPageBackgroundColor),
                                                       stroke: Color(NSColor.white).opacity(0.1)))
                    }
                }
                .padding(10)
            } else {
                Spacer()
            }
        }
    }
}

