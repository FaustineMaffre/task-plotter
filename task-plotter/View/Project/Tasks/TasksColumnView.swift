//
//  TasksColumnView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 17/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct TasksColumnView<MenuItems: View>: View {
    @Binding var columnTasks: [Task]
    let isValidated: Bool
    
    let projectLabels: IndexedArray<Label, LabelID>
    
    let onTap: (Int) -> Void
    
    let dragItem: (Task) -> NSItemProvider
    let onDropAction: (NSItemProvider, Int) -> Void
    
    let taskContentMenu: (Int) -> MenuItems
    
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
                            self.taskContentMenu(taskIndex)
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
