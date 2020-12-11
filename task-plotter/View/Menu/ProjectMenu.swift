//
//  ProjectMenu.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

// TODO4 edit available labels

struct ProjectMenu: View {
    @ObservedObject var repository: Repository
    
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
            CreateProjectButton(repository: self.repository, showText: true)
            
            // delete project
            DeleteProjectButton(repository: self.repository, showText: true)
        }
    }
}

