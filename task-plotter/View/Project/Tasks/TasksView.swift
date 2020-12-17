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
    
    @Binding var version: Version
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
                
                VersionDatesView(version: self.$version)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
                HStack(spacing: 8) {
                    ForEach(self.version.ҩtasksByColumnArray, id: \.0) { column, tasks in
                        self.columView(column: column, tasks: self.generateTasksBinding(column: column))
                    }
                }
                .padding(10)
            }
            .sheet(item: self.$taskCreationOrEditionSheetItem) { mode in
                switch mode {
                case .creation:
                    TaskCreationModal(version: self.$version,
                                      projectLabels: self.project.labels,
                                      column: self.taskToCreateOrEditColumn)
                case .edition:
                    TaskEditionModal(version: self.$version,
                                     projectLabels: self.project.labels,
                                     column: self.taskToCreateOrEditColumn,
                                     taskIndex: self.taskToEditIndex)
                }
            }
            .deleteTaskAlert(isPresented: self.$isTaskDeletionAlertPresented,
                             version: self.$version,
                             column: self.taskToDeleteColumn,
                             taskToDeleteIndex: self.taskToDeleteIndex)
        } sideContent: {
            Text("Pool")
                .frame(width: 360)
        }
    }
    
    func columView(column: Column, tasks: Binding<[Task]>) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(column.rawValue)
                    .smallTitleStyle()
                    .padding(10)
                
                Spacer()
            }
            
            TasksColumnView(tasks: tasks,
                            isValidated: column == .done,
                            projectLabels: self.project.labels,
                            onTap: { taskIndex in
                                self.taskToEditIndex = taskIndex
                                self.taskToCreateOrEditColumn = column
                                self.taskCreationOrEditionSheetItem = .edition
                            },
                            onInsert: { index, str in
                                if let taskId = UUID(uuidString: str) {
                                    self.moveTask(taskId: taskId, newColumn: column, index: index)
                                }
                            },
                            taskContentMenu: { taskIndex in
                                HStack {
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
                            })
            
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
    
    func generateTasksBinding(column: Column) -> Binding<[Task]> {
        Binding {
            self.version.tasksByColumn[column]!
        } set: {
            self.version.tasksByColumn[column] = $0
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

