//
//  ContentView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var repository: Repository
    
    var body: some View {
        if let selectedProject = self.repository.selectedProject {
            VStack(spacing: 0) {
                ProjectMenu(repository: self.repository)
                    .padding(10)
                
                ProjectView(project: selectedProject)
            }
        } else {
            // no projects
            EmptyProjectsView(repository: self.repository)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repository: TestRepositories.repository)
            .environmentObject(UserDefaultsConfig.shared)
            .previewLayout(.fixed(width: 800, height: 600))
    }
}