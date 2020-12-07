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
    
    var body: some View {
        NavigationView {
            // versions
            VStack(spacing: 0) {
                HStack {
                    Text("Versions")
                        .font(.title2)
                        .padding(10)
                    
                    Spacer()
                }
                
                List {
                    ForEach(self.project.versions) { version in
                        HStack {
                            Text(version.number)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.userDefaults.selectedVersionId = version.id
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(RoundedRectangle(cornerRadius: 8)
                                            .fill(self.project.selectedVersion == version ? Color.accentColor : Color.clear))
                    }
                    
                    CreateVersionButton(project: self.$project)
                }
            }
            
            // tasks
            if let selectedVersion = self.project.selectedVersion {
                VStack(spacing: 0) {
                    HStack {
                        Text("Tasks")
                            .font(.title2)
                            .padding(10)
                        
                        Spacer()
                    }
                    
                    List {
                        ForEach(selectedVersion.tasks) { task in
                            Text(task.title)
                        }
                    }
                }
            } else {
                Text("Create or select a version")
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
