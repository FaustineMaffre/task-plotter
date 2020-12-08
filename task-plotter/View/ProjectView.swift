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
            // versions
            VersionsView(repository: self.repository)
            
            // tasks
            VStack(spacing: 0) {
                HStack {
                    Text("Tasks")
                        .titleStyle()
                        .padding(10)
                    
                    Spacer()
                }
                
                if let selectedVersion = self.repository.ҩselectedProject?.ҩselectedVersion {
                    List {
                        ForEach(selectedVersion.tasks) { task in
                            Text(task.title)
                        }
                    }
                } else {
                    Spacer()
                }
            }
        }
    }
}
