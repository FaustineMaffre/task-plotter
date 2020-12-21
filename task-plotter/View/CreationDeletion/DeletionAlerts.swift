//
//  DeletionAlerts.swift
//  task-plotter
//
//  Created by Faustine Maffre on 11/12/2020.
//

import SwiftUI

extension View {
    func deleteProjectAlert(isPresented: Binding<Bool>, repository: Repository, projectToDeleteIndex: Int) -> some View {
        let projectName: String
        if repository.projects.indices.contains(projectToDeleteIndex) {
            projectName = repository.projects[projectToDeleteIndex].name
        } else {
            projectName = ""
        }
        
        let deleteAction: () -> Void = {
            repository.projects.remove(at: projectToDeleteIndex)
        }
        
        return self
            .alert(isPresented: isPresented) {
                Alert(title: Text("Delete project"),
                      message: Text("Are you sure you want to delete project \"\(projectName)\"?"),
                      primaryButton: .destructive(Text("Delete"), action: deleteAction),
                      secondaryButton: .cancel())
            }
    }
    
    func deleteVersionAlert(isPresented: Binding<Bool>, project: Binding<Project>, versionToDeleteIndex: Int?) -> some View {
        let versionNumber: String
        if let index = versionToDeleteIndex,
           project.wrappedValue.versions.indices.contains(index) {
            versionNumber = project.wrappedValue.versions[index].number
        } else {
            versionNumber = ""
        }
        
        let deleteAction: () -> Void = {
            if let index = versionToDeleteIndex {
                project.versions.wrappedValue.remove(at: index)
            }
        }
        
        return self
            .alert(isPresented: isPresented) {
                Alert(title: Text("Delete version"),
                      message: Text("Are you sure you want to delete version \"\(versionNumber)\"?"),
                      primaryButton: .destructive(Text("Delete"), action: deleteAction),
                      secondaryButton: .cancel())
            }
    }
    
    func deleteTaskAlert(isPresented: Binding<Bool>,
                         project: Binding<Project>, version: Binding<Version>,
                         column: Column?, taskToDeleteIndex: Int) -> some View {
        let columnTasks = Column.columnTasksBinding(project: project, version: version, column: column)
        
        let taskTitle: String
        if columnTasks.wrappedValue.indices.contains(taskToDeleteIndex) {
            taskTitle = columnTasks.wrappedValue[taskToDeleteIndex].title
        } else {
            taskTitle = ""
        }
        
        let deleteAction: () -> Void = {
            columnTasks.wrappedValue.remove(at: taskToDeleteIndex)
        }
        
        return self
            .alert(isPresented: isPresented) {
                Alert(title: Text("Delete task"),
                      message: Text("Are you sure you want to delete the task \"\(taskTitle)\"?"),
                      primaryButton: .destructive(Text("Delete"), action: deleteAction),
                      secondaryButton: .cancel())
            }
    }
}
