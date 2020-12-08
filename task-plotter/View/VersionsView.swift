//
//  VersionsView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct VersionsView: View {
    @ObservedObject var repository: Repository
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Versions")
                    .titleStyle()
                    .padding(10)
                
                Spacer()
            }
            
            if let selectedProjectIndex = self.repository.ҩselectedProjectIndex,
               let selectedProject = self.repository.ҩselectedProject {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(selectedProject.versions) { version in
                            HStack {
                                Text(version.number)
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.repository.projects[selectedProjectIndex].selectedVersionId = version.id
                            }
                            .background(RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedProject.ҩselectedVersion == version ? Color.accentColor : Color.clear))
                        }
                    }
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                }
                
                HStack(spacing: 0) {
                    Spacer()
                    CreateVersionButton(repository: self.repository, showText: false)
                    DeleteVersionButton(repository: self.repository, showText: false)
                }
            } else {
                Spacer()
            }
        }
    }
}

