//
//  ProjectView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ProjectView: View {
    @EnvironmentObject var userDefaults: UserDefaultsConfig
    @State var project: Project
    
    @State var isVersionCreationSheetPresented: Bool = false
    
    var selectedVersion: Version? {
        self.project.versions.first { $0.id == self.userDefaults.selectedVersionId }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.project.versions) { version in
                    Text(version.number)
                }
                
                CreateVersionButton(project: self.$project)
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
                Text("Create or select version")
            }
        }
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        return ProjectView(project: TestRepositories.repository.projects[0])
            .environmentObject(UserDefaultsConfig.shared)
            .previewLayout(.fixed(width: 800, height: 600))
    }
}
