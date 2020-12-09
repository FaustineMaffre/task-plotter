//
//  VersionsView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct VersionsView: View {
    @Binding var project: Project
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Versions")
                    .titleStyle()
                    .padding(10)
                
                Spacer()
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.project.versions) { version in
                        HStack {
                            Text(version.number)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.project.selectedVersionId = version.id
                        }
                        .background(RoundedRectangle(cornerRadius: 8)
                                        .fill(self.project.ҩselectedVersion == version ? Color.accentColor : Color.clear))
                    }
                }
                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
            }
            
            HStack(spacing: 0) {
                Spacer()
                CreateVersionButton(project: self.$project, showText: false)
                DeleteVersionButton(project: self.$project, showText: false)
            }
        }
    }
}

