//
//  ProjectMenu.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

/// Menu at the top of the window, showing project list and operations. 
struct ProjectMenu: View {
    @ObservedObject var repository: Repository
    
    @State var projectCreationOrEditionSheetItem: CreationOrEditionMode? = nil
    @State var projectToEditIndex: Int = 0
    
    @State var isProjectDeletionAlertPresented: Bool = false
    @State var projectToDeleteIndex: Int = 0
    
    var body: some View {
        HStack(spacing: 4) {
            // projects menu
            Menu(self.repository.ҩselectedProject?.name ?? "") {
                ForEach(self.repository.projects, id: \.self) { project in
                    Button(project.name) {
                        self.repository.selectedProjectId = project.id
                    }
                }
            }
            .frame(width: 200)
            
            // edit project
            CreateDeleteEditButton(image: Image(systemName: "pencil"), text: "Edit project") {
                if let index = self.repository.ҩselectedProjectIndex {
                    self.projectToEditIndex = index
                    self.projectCreationOrEditionSheetItem = .edition
                }
            }
            .disabled(self.repository.ҩselectedProject == nil)
            
            Spacer()
            
            // create project
            CreateDeleteEditButton(image: Image(systemName: "plus"), text: "Create a project") {
                self.projectCreationOrEditionSheetItem = .creation
            }
            
            // delete project
            CreateDeleteEditButton(image: Image(systemName: "minus"), text: "Delete project") {
                if let index = self.repository.ҩselectedProjectIndex {
                    self.projectToDeleteIndex = index
                    self.isProjectDeletionAlertPresented = true
                }
            }
            .disabled(self.repository.ҩselectedProject == nil)
        }
        .sheet(item: self.$projectCreationOrEditionSheetItem) { mode in
            switch mode {
            case .creation:
                ProjectCreationModal(repository: self.repository)
            case .edition:
                ProjectEditionModal(repository: self.repository,
                                    projectIndex: self.projectToEditIndex)
            }
        }
        .deleteProjectAlert(isPresented: self.$isProjectDeletionAlertPresented,
                            repository: self.repository,
                            projectToDeleteIndex: self.projectToDeleteIndex)
    }
}

