//
//  TasksView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct TasksView: View {
    @Binding var project: Project
    let versionIndex: Int
    
    @State var isTasksPoolPresented: Bool = false
    
    @State var taskCreationOrEditionSheetItem: CreationOrEditionMode? = nil
    @State var taskToCreateOrEditColumn: Column = .todo
    @State var taskToEditIndex: Int = 0
    
    @State var isTaskDeletionAlertPresented: Bool = false
    @State var taskToDeleteColumn: Column = .todo
    @State var taskToDeleteIndex: Int = -1
    
    var body: some View {
        SideMenu(side: .trailing, isPresented: self.$isTasksPoolPresented) {
            VStack(spacing: 0) {
                HStack {
                    Text("Tasks")
                        .titleStyle()
                    
                    Spacer()
                    
                    // pool menu button
                    Button {
                        withAnimation {
                            self.isTasksPoolPresented.toggle()
                        }
                    } label: {
                        Image(systemName: "archivebox")
                            .imageScale(.large)
                    }
                }
                .padding(10)
                
                VersionDatesView(version: self.generateVersionBinding())
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
                HStack(spacing: 8) {
                    ForEach(self.project.versions[self.versionIndex].ҩtasksByColumnArray, id: \.0) { column, tasks in
                        self.columView(column: column, tasks: tasks)
                    }
                }
                .padding(10)
            }
            .sheet(item: self.$taskCreationOrEditionSheetItem) { mode in
                switch mode {
                case .creation:
                    TaskCreationModal(version: self.generateVersionBinding(),
                                      projectLabels: self.project.labels,
                                      column: self.taskToCreateOrEditColumn)
                case .edition:
                    TaskEditionModal(version: self.generateVersionBinding(),
                                     projectLabels: self.project.labels,
                                     column: self.taskToCreateOrEditColumn,
                                     taskIndex: self.taskToEditIndex)
                }
            }
            .deleteTaskAlert(isPresented: self.$isTaskDeletionAlertPresented,
                             version: self.generateVersionBinding(),
                             column: self.taskToDeleteColumn,
                             taskToDeleteIndex: self.taskToDeleteIndex)
        } sideContent: {
            Text("Pool")
                .frame(width: 360)
        }
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
                                 projectLabels: self.project.labels)
                            .onTapGesture {
                                self.taskToEditIndex = taskIndex
                                self.taskToCreateOrEditColumn = column
                                self.taskCreationOrEditionSheetItem = .edition
                            }
                            .onDrag { NSItemProvider(object: tasks[taskIndex].id.uuidString as NSString) }
                            .contextMenu {
                                Menu("Move to") {
                                    ForEach(self.project.versions.indices, id: \.self) { otherVersionIndex in
                                        if otherVersionIndex != self.versionIndex {
                                            Button(self.project.versions[otherVersionIndex].number) {
                                                self.project.moveTaskTo(taskCurrentVersionIndex: self.versionIndex,
                                                                        taskCurrentColumn: column,
                                                                        taskIndex: taskIndex,
                                                                        destinationVersionIndex: otherVersionIndex)
                                            }
                                        }
                                    }
                                }
                                
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
        .frame(width: 360)
        .background(RoundedRectangle(cornerRadius: 8)
                        .fillAndStroke(fill: Color(NSColor.underPageBackgroundColor),
                                       stroke: Color.white.opacity(0.1)))
    }
    
    func generateVersionBinding() -> Binding<Version> {
        Binding {
            if self.project.versions.indices.contains(self.versionIndex) {
                return self.project.versions[self.versionIndex]
            } else {
                return Version(number: "Oops")
            }
        } set: {
            if self.project.versions.indices.contains(self.versionIndex) {
                self.project.versions[self.versionIndex] = $0
            }
        }
    }
    
    func generateTaskBinding(column: Column, taskIndex: Int) -> Binding<Task> {
        Binding {
            if self.project.versions.indices.contains(self.versionIndex),
               self.project.versions[self.versionIndex].tasksByColumn[column]!.indices.contains(taskIndex) {
                return self.project.versions[self.versionIndex].tasksByColumn[column]![taskIndex]
            } else {
                return Task(title: "Oops")
            }
        } set: {
            if self.project.versions.indices.contains(self.versionIndex),
               self.project.versions[self.versionIndex].tasksByColumn[column]!.indices.contains(taskIndex) {
                self.project.versions[self.versionIndex].tasksByColumn[column]![taskIndex] = $0
            }
        }
    }
    
    func moveTask(taskId: TaskID, newColumn: Column, index: Int) {
        DispatchQueue.main.async {
            // find old column
            if let oldColumn = self.project.versions[self.versionIndex].findColumnOfTask(id: taskId),
               let taskOldIndex = self.project.versions[self.versionIndex].tasksByColumn[oldColumn]!.firstIndex(where: { $0.id == taskId }) {
                let task = self.project.versions[self.versionIndex].tasksByColumn[oldColumn]![taskOldIndex]
                
                if oldColumn != newColumn {
                    // change column
                    self.project.versions[self.versionIndex].tasksByColumn[oldColumn]!.remove(at: taskOldIndex)
                    
                    if self.project.versions[self.versionIndex].tasksByColumn[newColumn]!.isEmpty {
                        // in case index would be outside bounds (because of empty tasks)
                        self.project.versions[self.versionIndex].tasksByColumn[newColumn]!.append(task)
                    } else {
                        self.project.versions[self.versionIndex].tasksByColumn[newColumn]!.insert(task, at: index)
                    }
                } else {
                    // move within same column
                    self.project.versions[self.versionIndex].tasksByColumn[newColumn]!.move(fromOffsets: IndexSet(arrayLiteral: taskOldIndex), toOffset: index)
                }
            }
        }
    }
}

