//
//  ContentView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userDefaults: UserDefaultsConfig
    @ObservedObject var repository: Repository
    
    var selectedProject: Project? {
        self.repository.projects.first { $0.id == self.userDefaults.selectedProjectId }
    }
    
    var selectedVersion: Version? {
        self.selectedProject?.versions.first { $0.id == self.userDefaults.selectedVersionId }
    }
    
    var body: some View {
        if self.repository.projects.isEmpty {
            EmptyProjectsView(repository: self.repository)
        } else {
            if let selectedProject = self.selectedProject {
                NavigationView {
                    List {
                        ForEach(selectedProject.versions) { version in
                            Text(version.number)
                        }
                    }
                    .navigationTitle("Versions")
                    
                    if let selectedVersion = self.selectedVersion {
                        List {
                            ForEach(selectedVersion.tasks) { task in
                                Text(task.title)
                            }
                        }
                        .navigationTitle("Tasks")
                    } else {
                        Text("Create version")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
//        UserDefaultsConfig.shared.selectedProjectId = project.id
//        UserDefaultsConfig.shared.selectedVersionId = version.id
        
        return ContentView(repository: TestRepositories.repository)
            .environmentObject(UserDefaultsConfig.shared)
            .previewLayout(.fixed(width: 800, height: 600))
    }
}
