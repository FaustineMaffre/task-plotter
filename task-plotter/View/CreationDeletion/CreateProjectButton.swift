//
//  CreateProjectButton.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct CreateProjectButton: View {
    @ObservedObject var repository: Repository
    
    @State var isProjectCreationSheetPresented: Bool = false
    @State var tempProjectName: String = ""
    
    let showText: Bool
    
    var body: some View {
        Button {
            self.isProjectCreationSheetPresented = true
        } label: {
            HStack(spacing: 0) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(width: 30, height: 30)
                
                if self.showText {
                    Text("Create a project")
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: self.$isProjectCreationSheetPresented) {
            VStack(spacing: 20) {
                Spacer()
                
                Text("Create a new project")
                    .font(.headline)
                
                HStack {
                    Text("Project name:")
                    TextField("", text: self.$tempProjectName)
                }
                
                HStack {
                    Button("Cancel", action: self.cancel)
                        .keyboardShortcut(.cancelAction)
                    
                    Button("Create", action: self.create)
                        .keyboardShortcut(.defaultAction)
                        .disabled(self.tempProjectName.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 300, height: 130)
        }
    }
    
    func create() {
        if !self.tempProjectName.isEmpty {
            self.repository.addProject(name: self.tempProjectName, selectIt: true)
            
            // close sheet and reset text
            self.isProjectCreationSheetPresented = false
            self.tempProjectName = ""
        }
    }
    
    func cancel() {
        // close sheet and reset text
        self.isProjectCreationSheetPresented = false
        self.tempProjectName = ""
    }
}
