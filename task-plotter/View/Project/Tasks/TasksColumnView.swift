//
//  TasksColumnView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 17/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

/// View of a column of a version, containing tasks. 
struct TasksColumnView<MenuItems: View>: View {
    @Binding var columnTasks: IndexedArray<Task, TaskID>
    
    /// True if the column should be considered as validated.
    let isValidated: Bool
    
    /// Labels of the project.
    let projectLabels: IndexedArray<Label, LabelID>
    
    /// Action on tap on the task view.
    let onTap: (Int) -> Void
    
    /// Item to be returned when drawing the given task in this column.
    let dragItem: (Task) -> NSItemProvider
    /// Action on drop of the given item in this column at the given index.
    let onDropAction: (NSItemProvider, Int) -> Void
    
    /// Context menu for the item at the given index.
    let taskContextMenu: (Int) -> MenuItems
    
    var body: some View {
        List {
            ForEach(self.columnTasks.isEmpty ? [-1] : Array(self.columnTasks.indices), id: \.self) { taskIndex in
                if taskIndex < 0 {
                    HStack {
                        Spacer()
                        Text("No task")
                            .foregroundColor(Color.white.opacity(0.2))
                        Spacer()
                    }
                } else {
                    TaskView(task: self.generateTaskBinding(taskIndex: taskIndex),
                             isValidated: self.isValidated,
                             projectLabels: self.projectLabels)
                        .onTapGesture {
                            self.onTap(taskIndex)
                        }
                        .onDrag { self.dragItem(self.columnTasks[taskIndex]) }
                        .contextMenu {
                            self.taskContextMenu(taskIndex)
                        }
                        .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                }
            }
            .onInsert(of: [UTType.plainText]) { index, items in
                items.forEach { item in
                    self.onDropAction(item, index)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    func generateTaskBinding(taskIndex: Int) -> Binding<Task> {
        Binding {
            if self.columnTasks.indices.contains(taskIndex) {
                return self.columnTasks[taskIndex]
            } else {
                return Task(title: "Oops")
            }
        } set: {
            if columnTasks.indices.contains(taskIndex) {
                self.columnTasks[taskIndex] = $0
            }
        }
    }
}
