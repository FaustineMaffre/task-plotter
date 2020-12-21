//
//  TasksView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

extension View {
    func background<Background: View>(isBackground: Bool, _ background: Background) -> some View {
        Group {
            if isBackground {
                self.background(background)
            } else {
                self
            }
        }
    }
}

/// View of tasks in a version, along with the common tasks pool of the project.
struct TasksView: View {
    @EnvironmentObject var userDefaultsConfig: UserDefaultsConfig
    
    @Binding var project: Project
    
    @Binding var version: Version
    let versionIndex: Int
    
    @State var taskCreationOrEditionSheetItem: CreationOrEditionMode? = nil
    @State var taskToCreateOrEditColumn: Column? = nil // nil for tasks pool
    @State var taskToEditIndex: Int = 0
    
    @State var isTaskDeletionAlertPresented: Bool = false
    @State var taskToDeleteColumn: Column? = nil // nil for tasks pool
    @State var taskToDeleteIndex: Int = -1
    
    var body: some View {
        SideMenu(side: .trailing, isPresented: self.$userDefaultsConfig.isTasksPoolVisible) {
            VStack(spacing: 0) {
                HStack {
                    Text("Tasks")
                        .titleStyle()
                    
                    Spacer()
                    
                    // pool menu button
                    Button {
                        withAnimation {
                            self.userDefaultsConfig.isTasksPoolVisible.toggle()
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
                        self.columnView(column: column)
                    }
                }
                .padding(10)
            }
            .sheet(item: self.$taskCreationOrEditionSheetItem) { mode in
                switch mode {
                case .creation:
                    TaskCreationModal(project: self.$project,
                                      version: self.$version,
                                      projectLabels: self.project.labels,
                                      column: self.taskToCreateOrEditColumn)
                case .edition:
                    TaskEditionModal(project: self.$project,
                                     version: self.$version,
                                     projectLabels: self.project.labels,
                                     column: self.taskToCreateOrEditColumn,
                                     taskIndex: self.taskToEditIndex)
                }
            }
            .deleteTaskAlert(isPresented: self.$isTaskDeletionAlertPresented,
                             project: self.$project,
                             version: self.$version,
                             column: self.taskToDeleteColumn,
                             taskToDeleteIndex: self.taskToDeleteIndex)
        } sideContent: {
            // tasks pool
            self.columnView(column: nil)
        }
    }
    
    /// View of a column or the tasks pool (if the given column is nil).
    func columnView(column: Column?) -> some View {
        let columnTasks = Column.columnTasksBinding(project: self.$project, version: self.$version, column: column)
        
        return VStack(spacing: 0) {
            HStack {
                Text(column?.rawValue ?? "Tasks pool")
                    .smallTitleStyle()
                
                Spacer()
            }
            .padding(10)
            
            TasksColumnView(columnTasks: columnTasks,
                            isValidated: column == .done,
                            projectLabels: self.project.labels,
                            onTap: { taskIndex in
                                self.taskToEditIndex = taskIndex
                                self.taskToCreateOrEditColumn = column
                                self.taskCreationOrEditionSheetItem = .edition
                            },
                            dragItem: { DraggedElement.toItemProvider(task: $0, column: column) },
                            onDropAction: { item, index in
                                DraggedElement.toTask(itemProvider: item, project: self.project, version: self.version) {
                                    if let (taskColumn, task) = $0 {
                                        self.moveTask(oldColumn: taskColumn, task: task, newColumn: column, index: index)
                                    }
                                }
                            },
                            taskContextMenu: { taskIndex in
                                HStack {
                                    if let column = column { // if in tasks pool, use drag and drop instead of menu
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
        .background(isBackground: column != nil, // no background in tasks pool
                    RoundedRectangle(cornerRadius: 8)
                        .fillAndStroke(fill: Color(NSColor.underPageBackgroundColor),
                                       stroke: Color.white.opacity(0.1)))
    }
    
    /// Moves a task to a column at the given index. A nil column indicates the tasks pool. 
    func moveTask(oldColumn: Column?, task: Task, newColumn: Column?, index: Int) {
        DispatchQueue.main.async {
            let oldColumnTasks = Column.columnTasksBinding(project: self.$project, version: self.$version, column: oldColumn)
            let newColumnTasks = Column.columnTasksBinding(project: self.$project, version: self.$version, column: newColumn)
            
            if let taskOldIndex = oldColumnTasks.wrappedValue.firstIndex(where: { $0.id == task.id }) {
                if oldColumn != newColumn {
                    // change column
                    oldColumnTasks.wrappedValue.remove(at: taskOldIndex)
                    
                    if newColumnTasks.wrappedValue.isEmpty {
                        // in case index would be outside bounds (because of empty tasks)
                        newColumnTasks.wrappedValue.append(task)
                    } else {
                        newColumnTasks.wrappedValue.insert(task, at: index)
                    }
                } else {
                    // move within same column
                    newColumnTasks.wrappedValue.move(fromOffsets: IndexSet(arrayLiteral: taskOldIndex), toOffset: index)
                }
            }
        }
    }
}

