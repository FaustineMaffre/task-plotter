//
//  EmptyProjectsView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct EmptyProjectsView: View {
    @EnvironmentObject var userDefaults: UserDefaultsConfig
    @ObservedObject var repository: Repository
    
    @State var isProjectCreationSheetPresented: Bool = false
    @State var tempProjectName: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    self.isProjectCreationSheetPresented = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                        Text("Create a project")
                    }
                    .padding()
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
            Spacer()
        }
        .sheet(isPresented: self.$isProjectCreationSheetPresented) {
            VStack(spacing: 20) {
                Spacer()
                
                Text("Create a new project")
                    .font(.headline)
                
                HStack {
                    Text("Project name:")
                    TextField("", text: self.$tempProjectName, onCommit: self.createProject)
                }
                
                Button("Create", action: self.createProject)
                    .disabled(self.tempProjectName.isEmpty)
                
                Spacer()
            }
            .padding()
            .frame(width: 300, height: 130)
        }
    }
    
    func createProject() {
        // create new project
        let newProject = Project(name: self.tempProjectName)
        self.repository.projects.append(newProject)
        
        // select it
        self.userDefaults.selectedProjectId = newProject.id

        // close sheet
        self.isProjectCreationSheetPresented = false
    }
}

struct EmptyProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyProjectsView(repository: Repository(labels: [], projects: []))
            .previewLayout(.fixed(width: 800, height: 600))
    }
}
