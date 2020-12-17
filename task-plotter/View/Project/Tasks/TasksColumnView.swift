//
//  TasksColumnView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 17/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct TasksColumnView<MenuItems: View>: View {
    @Binding var tasks: [Task]
    let isValidated: Bool
    
    let projectLabels: [Label]
    
    let onTap: (Int) -> Void
    let onInsert: (Int, String) -> Void
    
    let taskContentMenu: (Int) -> MenuItems
    
    var body: some View {
        List {
            ForEach(self.tasks.isEmpty ? [-1] : Array(self.tasks.indices), id: \.self) { taskIndex in
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
                        .onDrag { NSItemProvider(object: tasks[taskIndex].id.uuidString as NSString) }
                        .contextMenu {
                            self.taskContentMenu(taskIndex)
                        }
                        .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                }
            }
            .onInsert(of: [UTType.plainText]) { index, items in
                items.forEach { item in
                    _ = item.loadObject(ofClass: String.self) { optionalStr, _ in
                        if let str = optionalStr {
                            self.onInsert(index, str)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    func generateTaskBinding(taskIndex: Int) -> Binding<Task> {
        Binding {
            if self.tasks.indices.contains(taskIndex) {
                return self.tasks[taskIndex]
            } else {
                return Task(title: "Oops")
            }
        } set: {
            if tasks.indices.contains(taskIndex) {
                self.tasks[taskIndex] = $0
            }
        }
    }
}
