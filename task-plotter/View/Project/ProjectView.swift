//
//  ProjectView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ProjectView: View {
    @ObservedObject var repository: Repository
    
    var body: some View {
        NavigationView {
            // versions on the left
            if let projectIndex = self.repository.ҩselectedProjectIndex {
                VersionsView(project: self.generateProjectBinding(projectIndex: projectIndex))
            } else {
                Spacer()
            }
            
            // tasks on the right
            if let projectIndex = self.repository.ҩselectedProjectIndex,
               let versionIndex = self.repository.projects[projectIndex].ҩselectedVersionIndex {
                TasksView(project: self.generateProjectBinding(projectIndex: projectIndex), versionIndex: versionIndex)
            } else {
                Spacer()
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
    
    func generateProjectBinding(projectIndex: Int) -> Binding<Project> {
        Binding {
            if self.repository.projects.indices.contains(projectIndex) {
                return self.repository.projects[projectIndex]
            } else {
                return Project(name: "Oops", labels: [])
            }
        } set: {
            if self.repository.projects.indices.contains(projectIndex) {
                self.repository.projects[projectIndex] = $0
            }
        }
    }
}
