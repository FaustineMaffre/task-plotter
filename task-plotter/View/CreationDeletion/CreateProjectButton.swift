//
//  CreateProjectButton.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct CreateProjectButton: View {
    @EnvironmentObject var userDefaults: UserDefaultsConfig
    @ObservedObject var repository: Repository
    
    @State var isProjectCreationSheetPresented: Bool = false
    @State var tempProjectName: String = ""
    
    var body: some View {
        Button {
            self.isProjectCreationSheetPresented = true
        } label: {
            HStack(spacing: 0) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(width: 30, height: 30)
                
                Text("Create a project")
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
                    TextField("", text: self.$tempProjectName, onCommit: self.create)
                }
                
                HStack {
                    Button("Cancel", action: self.cancel)
                    
                    Button("Create", action: self.create)
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