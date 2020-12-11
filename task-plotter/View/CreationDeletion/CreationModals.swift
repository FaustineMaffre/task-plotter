//
//  CreationModals.swift
//  task-plotter
//
//  Created by Faustine Maffre on 11/12/2020.
//

import SwiftUI

// MARK: - Generics

enum CreationOrEditionMode: Identifiable {
    case creation, edition
    
    var id: CreationOrEditionMode { self }
}

struct CreationOrEditionModal<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode
    
    let mode: CreationOrEditionMode
    
    let titleText: String
    let propertiesView: () -> Content
    
    let createOrEditCondition: Bool
    
    let createOrEditAction: () -> Void
    let cancelAction: () -> Void
    let resetAction: () -> Void
    
    var createOrEditButtonText: String {
        switch self.mode {
        case .creation: return "Create"
        case .edition: return "Edit"
        }
    }
    
    init(mode: CreationOrEditionMode,
         titleText: String,
         propertiesView: @escaping () -> Content,
         createOrEditCondition: Bool,
         createOrEditAction: @escaping () -> Void,
         cancelAction: @escaping () -> Void = {},
         resetAction: @escaping () -> Void) {
        
        self.mode = mode
        self.titleText = titleText
        self.propertiesView = propertiesView
        self.createOrEditCondition = createOrEditCondition
        self.createOrEditAction = createOrEditAction
        self.cancelAction = cancelAction
        self.resetAction = resetAction
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(self.titleText)
                .font(.headline)
            
            Spacer()
                .frame(height: 20)
            
            self.propertiesView()
            
            Spacer()
            
            HStack {
                Button("Cancel", action: self.cancel)
                    .keyboardShortcut(.cancelAction)
                
                Button(self.createOrEditButtonText, action: self.createOrEdit)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!self.createOrEditCondition)
            }
        }
        .padding()
        .frame(width: 300, height: 130)
    }
    
    func createOrEdit() {
        if self.createOrEditCondition {
            self.createOrEditAction()
            
            self.presentationMode.wrappedValue.dismiss()
            self.resetAction()
        }
    }
    
    func cancel() {
        self.cancelAction()
        
        self.presentationMode.wrappedValue.dismiss()
        self.resetAction()
    }
}

// MARK: - Project

struct ProjectFormContent: View {
    @Binding<String> var projectName: String
    
    var body: some View {
        HStack(spacing: 20) {
            Text("Name")
            TextField("", text: self.$projectName)
        }
    }
}

struct ProjectCreationModal: View {
    let repository: Repository
    @Binding var tempProjectName: String
    
    var body: some View {
        CreationOrEditionModal(
            mode: .creation,
            titleText: "Create a new project",
            propertiesView: {
                ProjectFormContent(projectName: self.$tempProjectName)
            }, createOrEditCondition: !self.tempProjectName.isEmpty) {
            // create
            self.repository.addProject(name: self.tempProjectName, selectIt: true)
        } resetAction: {
            // reset project name
            self.tempProjectName = ""
        }
    }
}

struct ProjectEditionModal: View {
    let repository: Repository
    let projectIndex: Int
    @Binding var tempProjectName: String
    
    var body: some View {
        CreationOrEditionModal(
            mode: .edition,
            titleText: "Edit project",
            propertiesView: {
                ProjectFormContent(projectName: self.$tempProjectName)
            }, createOrEditCondition: !self.tempProjectName.isEmpty) {
            // edit
            self.repository.projects[projectIndex].name = self.tempProjectName
        } resetAction: {
            // reset project name
            self.tempProjectName = ""
        }
    }
}

// MARK: - Version

struct VersionFormContent: View {
    @Binding<String> var versionNumber: String
    
    var body: some View {
        
        HStack(spacing: 20) {
            Text("Number")
            TextField("", text: self.$versionNumber)
        }
    }
}

struct VersionCreationModal: View {
    @Binding var project: Project
    @Binding var tempVersionNumber: String
    
    var body: some View {
        CreationOrEditionModal(
            mode: .creation,
            titleText: "Add a new version",
            propertiesView: {
                ProjectFormContent(projectName: self.$tempVersionNumber)
            }, createOrEditCondition: !self.tempVersionNumber.isEmpty) {
            // create
            self.project.addVersion(number: self.tempVersionNumber, selectIt: true)
        } resetAction: {
            // reset version number
            self.tempVersionNumber = ""
        }
    }
}

struct VersionEditionModal: View {
    @Binding var project: Project
    let versionIndex: Int
    @Binding var tempVersionNumber: String
    
    var body: some View {
        CreationOrEditionModal(
            mode: .edition,
            titleText: "Edit version",
            propertiesView: {
                ProjectFormContent(projectName: self.$tempVersionNumber)
            }, createOrEditCondition: !self.tempVersionNumber.isEmpty) {
            // edit
            self.project.versions[versionIndex].number = self.tempVersionNumber
        } resetAction: {
            // reset project name
            self.tempVersionNumber = ""
        }
    }
}

// MARK: - Task

extension View {
    
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
