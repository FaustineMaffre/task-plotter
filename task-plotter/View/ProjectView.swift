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
        if let selectedProject = self.repository.ҩselectedProject {
            NavigationView {
                // versions
                VersionsView(repository: self.repository)
                
                // tasks
                if let selectedVersion = selectedProject.ҩselectedVersion {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Tasks")
                                .titleStyle()
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
