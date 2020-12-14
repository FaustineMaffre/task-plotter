//
//  TasksView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct TasksView: View {
    @Binding var version: Version
    let projectLabels: [Label]
    
    @State var taskCreationOrEditionSheetItem: CreationOrEditionMode? = nil
    @State var taskToCreateOrEditColumn: Column = .todo
    @State var taskToEditIndex: Int = 0
    
    @State var isTaskDeletionAlertPresented: Bool = false
    @State var taskToDeleteColumn: Column = .todo
    @State var taskToDeleteIndex: Int = -1
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tasks")
                    .titleStyle()
                    .padding(10)
                
                Spacer()
            }
            
            VersionDatesView(version: self.$version)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            
            HStack(spacing: 8) {
                ForEach(self.version.ҩtasksByColumnArray, id: \.0) { column, tasks in
                    self.columView(column: column, tasks: tasks)
                }
            }
            .padding(10)
        }
        .sheet(item: self.$taskCreationOrEditionSheetItem) { mode in
            switch mode {
            case .creation:
                TaskCreationModal(version: self.$version,
                                  projectLabels: self.projectLabels,
                                  column: self.taskToCreateOrEditColumn)
            case .edition:
                TaskEditionModal(version: self.$version,
                                 projectLabels: self.projectLabels,
                                 column: self.taskToCreateOrEditColumn,
                                 taskIndex: self.taskToEditIndex)
            }
        }
        .deleteTaskAlert(isPresented: self.$isTaskDeletionAlertPresented,
                         version: self.$version,
                         column: self.taskToDeleteColumn,
                         taskToDeleteIndex: self.taskToDeleteIndex)
    }
    
    func columView(column: Column, tasks: [Task]) -> some View {
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
                        TaskView(task: self.generateTaskBinding(column: column, taskIndex: taskIndex),
                                 column: column,
                                 projectLabels: self.projectLabels)
                            .onTapGesture {
                                self.taskToEditIndex = taskIndex
                                self.taskToCreateOrEditColumn = column
                                self.taskCreationOrEditionSheetItem = .edition
                            }
                            // TODO drop to another version
                            .onDrag { NSItemProvider(object: tasks[taskIndex].id.uuidString as NSString) }
                            .contextMenu {
                                Button("Delete") {
                                    self.taskToDeleteColumn = column
                                    self.taskToDeleteIndex = taskIndex
                                    self.isTaskDeletionAlertPresented = true
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                    }
                }
                .onInsert(of: [UTType.plainText]) { index, items in
                    items.forEach { item in
                        _ = item.loadObject(ofClass: String.self) { str, _ in
                            if let taskIdStr = str,
                               let taskId = UUID(uuidString: taskIdStr) {
                                self.moveTask(taskId: taskId, newColumn: column, index: index)
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            
            HStack {
                CreateDeleteEditButton(image: Image(systemName: "plus"), text: "Add a task") {
                    self.taskToCreateOrEditColumn = column
                    self.taskCreationOrEditionSheetItem = .creation
                }
                Spacer()
            }
        }
        .frame(width: 320)
        .background(RoundedRectangle(cornerRadius: 8)
                        .fillAndStroke(fill: Color(NSColor.underPageBackgroundColor),
                                       stroke: Color.white.opacity(0.1)))
    }
    
    func generateTaskBinding(column: Column, taskIndex: Int) -> Binding<Task> {
        Binding {
            if self.version.tasksByColumn[column]!.indices.contains(taskIndex) {
                return self.version.tasksByColumn[column]![taskIndex]
            } else {
                return Task(title: "Oops")
            }
        } set: {
            if self.version.tasksByColumn[column]!.indices.contains(taskIndex) {
                self.version.tasksByColumn[column]![taskIndex] = $0
            }
        }
    }
    
    func moveTask(taskId: TaskID, newColumn: Column, index: Int) {
        DispatchQueue.main.async {
            // find old column
            if let oldColumn = self.version.findColumnOfTask(id: taskId),
               let taskOldIndex = self.version.tasksByColumn[oldColumn]!.firstIndex(where: { $0.id == taskId }) {
                let task = self.version.tasksByColumn[oldColumn]![taskOldIndex]
                
                if oldColumn != newColumn {
                    // change column
                    self.version.tasksByColumn[oldColumn]!.remove(at: taskOldIndex)
                    
                    if self.version.tasksByColumn[newColumn]!.isEmpty {
                        // in case index would be outside bounds (because of empty tasks)
                        self.version.tasksByColumn[newColumn]!.append(task)
                    } else {
                        self.version.tasksByColumn[newColumn]!.insert(task, at: index)
                    }
                } else {
                    // move within same column
                    self.version.tasksByColumn[newColumn]!.move(fromOffsets: IndexSet(arrayLiteral: taskOldIndex), toOffset: index)
                }
            }
        }
    }
}

