//
//  TasksView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

// TODO1 delete task

// TODO5 due date
// TODO6 points per day, working days, excluded dates
// TODO7 compute dates per task

struct TasksView: View {
    @Binding var version: Version
    let labels: [Label]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tasks")
                    .titleStyle()
                    .padding(10)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(self.version.ҩtasksByColumnArray, id: \.0) { column, tasks in
                    VStack(spacing: 0) {
                        HStack {
                            Text(column.rawValue)
                                .smallTitleStyle()
                                .padding(10)
                            
                            Spacer()
                        }
                        
                        List {
                            ForEach(tasks.isEmpty ? [-1] : Array(tasks.indices), id: \.self) { taskIndex in
                                if taskIndex < 0 {
                                    HStack {
                                        Spacer()
                                        Text("No task")
                                            .foregroundColor(Color.white.opacity(0.2))
                                        Spacer()
                                    }
                                } else {
                                    TaskView(task: self.generateTaskBinding(column: column, taskIndex: taskIndex), column: column, labels: self.labels)
                                        .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                                        .onDrag { NSItemProvider(object: tasks[taskIndex].id.uuidString as NSString) }
                                }
                            }
                            .onInsert(of: [UTType.plainText]) { index, items in
                                items.forEach { item in
                                    _ = item.loadObject(ofClass: String.self) { str, _ in
                                        if let taskIdStr = str,
                                           let taskId = UUID(uuidString: taskIdStr) {
                                            DispatchQueue.main.async {
                                                // find old column
                                                if let oldColumn = self.version.findColumnOfTask(id: taskId),
                                                   let taskOldIndex = self.version.tasksByColumn[oldColumn]!.firstIndex(where: { $0.id == taskId }) {
                                                    let task = self.version.tasksByColumn[oldColumn]![taskOldIndex]
                                                    
                                                    if oldColumn != column {
                                                        // change column
                                                        self.version.tasksByColumn[oldColumn]!.remove(at: taskOldIndex)
                                                        
                                                        if self.version.tasksByColumn[column]!.isEmpty {
                                                            // in case index would be outside bounds (because of empty tasks)
                                                            self.version.tasksByColumn[column]!.append(task)
                                                        } else {
                                                            self.version.tasksByColumn[column]!.insert(task, at: index)
                                                        }
                                                    } else {
                                                        // move within same column
                                                        self.version.tasksByColumn[column]!.move(fromOffsets: IndexSet(arrayLiteral: taskOldIndex), toOffset: index)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        HStack {
                            CreateTaskButton(version: self.$version, column: column, showText: true)
                            Spacer()
                        }
                    }
                    .frame(width: 320)
                    .background(RoundedRectangle(cornerRadius: 8)
                                    .fillAndStroke(fill: Color(NSColor.underPageBackgroundColor),
                                                   stroke: Color.white.opacity(0.1)))
                }
            }
            .padding(10)
        }
    }
    
    func generateTaskBinding(column: Column, taskIndex: Int) -> Binding<Task> {
        Binding {
            self.version.tasksByColumn[column]![taskIndex]
        } set: {
            self.version.tasksByColumn[column]![taskIndex] = $0
        }
    }
}

