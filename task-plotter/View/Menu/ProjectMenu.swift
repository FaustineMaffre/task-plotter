//
//  ProjectMenu.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

// TODO3 edit project name

// TODO4 edit available labels

struct ProjectMenu: View {
    @ObservedObject var repository: Repository
    
    @State var isProjectCreationSheetPresented: Bool = false
    @State var tempProjectName: String = ""
    
    @State var isProjectDeletionAlertPresented: Bool = false
    @State var projectToDeleteIndex: Int? = 0
    
    var body: some View {
        HStack(spacing: 4) {
            // projects menu
            MenuButton(self.repository.ҩselectedProject?.name ?? "") {
                ForEach(self.repository.projects) { project in
                    Button(project.name) {
                        self.repository.selectedProjectId = project.id
                    }
                }
            }
            .frame(width: 200)
            
            Spacer()
            
            // create project
            CreateDeleteButton(image: Image(systemName: "plus"), text: "Create a project") {
                self.isProjectCreationSheetPresented = true
            }
            
            // delete project
            CreateDeleteButton(image: Image(systemName: "minus"), text: "Delete the project") {
                self.projectToDeleteIndex = self.repository.ҩselectedProjectIndex
                self.isProjectDeletionAlertPresented = true
            }
        }
        .createProjectModal(isPresented: self.$isProjectCreationSheetPresented,
                            repository: self.repository,
                            tempProjectName: self.$tempProjectName)
        .deleteProjectAlert(isPresented: self.$isProjectDeletionAlertPresented,
                            repository: self.repository,
                            projectToDeleteIndex: self.projectToDeleteIndex)
    }
}

