//
//  CreationModals.swift
//  task-plotter
//
//  Created by Faustine Maffre on 11/12/2020.
//

import SwiftUI

extension View {
    func createProjectModal(isPresented: Binding<Bool>, repository: Repository, tempProjectName: Binding<String>) -> some View {
        let create: () -> Void = {
            if !tempProjectName.wrappedValue.isEmpty {
                repository.addProject(name: tempProjectName.wrappedValue, selectIt: true)
                
                // close sheet and reset text
                isPresented.wrappedValue = false
                tempProjectName.wrappedValue = ""
            }
        }
        
        let cancel: () -> Void = {
            // close sheet and reset text
            isPresented.wrappedValue = false
            tempProjectName.wrappedValue = ""
        }
        
        return self
            .sheet(isPresented: isPresented) {
                VStack(spacing: 0) {
                    Text("Create a new project")
                        .font(.headline)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack(spacing: 20) {
                        Text("Name")
                        TextField("", text: tempProjectName)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button("Cancel", action: cancel)
                            .keyboardShortcut(.cancelAction)
                        
                        Button("Create", action: create)
                            .keyboardShortcut(.defaultAction)
                            .disabled(tempProjectName.wrappedValue.isEmpty)
                    }
                }
                .padding()
                .frame(width: 300, height: 130)
            }
    }
    
    func createVersionModal(isPresented: Binding<Bool>, project: Binding<Project>, tempVersionNumber: Binding<String>) -> some View {
        let create: () -> Void = {
            if !tempVersionNumber.wrappedValue.isEmpty {
                project.wrappedValue.addVersion(number: tempVersionNumber.wrappedValue, selectIt: true)
                
                // close sheet and reset text
                isPresented.wrappedValue = false
                tempVersionNumber.wrappedValue = ""
            }
        }
        
        let cancel: () -> Void = {
            // close sheet and reset text
            isPresented.wrappedValue = false
            tempVersionNumber.wrappedValue = ""
        }
        
        return self
            .sheet(isPresented: isPresented) {
                VStack(spacing: 0) {
                    Text("Add a new version")
                        .font(.headline)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack(spacing: 20) {
                        Text("Number")
                        TextField("", text: tempVersionNumber)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button("Cancel", action: cancel)
                            .keyboardShortcut(.cancelAction)
                        
                        Button("Create", action: create)
                            .keyboardShortcut(.defaultAction)
                            .disabled(tempVersionNumber.wrappedValue.isEmpty)
                    }
                }
                .padding()
                .frame(width: 300, height: 130)
            }
    }
    
    func createTaskModal(isPresented: Binding<Bool>, version: Binding<Version>, column: Column, tempTaskTitle: Binding<String>) -> some View {
        let create: () -> Void = {
            if !tempTaskTitle.wrappedValue.isEmpty {
                version.wrappedValue.addTask(column: column, title: tempTaskTitle.wrappedValue)
                
                // close sheet and reset text
                isPresented.wrappedValue = false
                tempTaskTitle.wrappedValue = ""
            }
        }
        
        let cancel: () -> Void = {
            // close sheet and reset text
            isPresented.wrappedValue = false
            tempTaskTitle.wrappedValue = ""
        }
        
        return self
            .sheet(isPresented: isPresented) {
                VStack(spacing: 0) {
                    Text("Add a new task")
                        .font(.headline)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HStack(spacing: 20) {
                        Text("Title")
                        TextField("", text: tempTaskTitle)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button("Cancel", action: cancel)
                            .keyboardShortcut(.cancelAction)
                        
                        Button("Create", action: create)
                            .keyboardShortcut(.defaultAction)
                            .disabled(tempTaskTitle.wrappedValue.isEmpty)
                    }
                }
                .padding()
                .frame(width: 300, height: 130)
            }
    }
}
