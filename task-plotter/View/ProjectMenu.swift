//
//  ProjectMenu.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ProjectMenu: View {
    @EnvironmentObject var userDefaults: UserDefaultsConfig
    @ObservedObject var repository: Repository
    
    var body: some View {
        if let selectedProject = self.repository.selectedProject {
            HStack(spacing: 16) {
                // projects menu
                MenuButton(selectedProject.name) {
                    ForEach(self.repository.projects) { project in
                        Button(project.name) {
                            self.userDefaults.selectedProjectId = project.id
                        }
                    }
                }
                .frame(width: 200)
                
                // delete project
                DeleteProjectButton(repository: self.repository)
                
                Spacer()
                
                // create project
                CreateProjectButton(repository: self.repository)
            }
        }
    }
}

