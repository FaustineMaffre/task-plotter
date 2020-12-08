//
//  ProjectMenu.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ProjectMenu: View {
    @ObservedObject var repository: Repository
    
    var body: some View {
        if let selectedProject = self.repository.ҩselectedProject {
            HStack(spacing: 4) {
                // projects menu
                MenuButton(selectedProject.name) {
                    ForEach(self.repository.projects) { project in
                        Button(project.name) {
                            self.repository.selectedProjectId = project.id
                        }
                    }
                }
                .frame(width: 200)
                
                Spacer()
                
                // create project
                CreateProjectButton(repository: self.repository)
                
                // delete project
                DeleteProjectButton(repository: self.repository)
            }
        }
    }
}

