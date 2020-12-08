//
//  ProjectView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ProjectView: View {
    @EnvironmentObject var userDefaults: UserDefaultsConfig
    @ObservedObject var repository: Repository
    
    @State var isVersionCreationSheetPresented: Bool = false
    
    var body: some View {
        if let selectedProject = self.repository.selectedProject {
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
                        ForEach(selectedProject.versions) { version in
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
                                                .fill(selectedProject.selectedVersion == version ? Color.accentColor : Color.clear))
                        }
                    }
                    
                    Divider()
                    
                    HStack(spacing: 0) {
                        Spacer() 
                        CreateVersionButton(repository: self.repository, showText: false)
                        DeleteVersionButton(repository: self.repository, showText: false)
                    }
                }
                
                // tasks
                if let selectedVersion = selectedProject.selectedVersion {
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
                }
            }
        }
    }
}
