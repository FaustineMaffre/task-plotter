//
//  VersionsView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct VersionsView: View {
    @Binding var project: Project
    
    @State var isVersionDeletionAlertPresented: Bool = false
    @State var versionToDeleteIndex: Int? = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // title
            HStack {
                Text("Versions")
                    .titleStyle()
                    .padding(10)
                
                Spacer()
            }
            
            // versions list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.project.versions.indices, id: \.self) { versionIndex in
                        HStack {
                            Text(self.project.versions[versionIndex].number)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.project.selectedVersionId = self.project.versions[versionIndex].id
                        }
                        .background(RoundedRectangle(cornerRadius: 8)
                                        .fill(self.project.ҩselectedVersionIndex == versionIndex ? Color.accentColor : Color.clear))
                        .contextMenu {
                            Button("Delete") {
                                self.versionToDeleteIndex = versionIndex
                                self.isVersionDeletionAlertPresented = true
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
            }
            
            // add/delete buttons
            HStack(spacing: 0) {
                Spacer()
                
                CreateVersionButton(project: self.$project, showText: false)
                
                Button {
                    self.versionToDeleteIndex = self.project.ҩselectedVersionIndex
                    self.isVersionDeletionAlertPresented = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "minus")
                            .imageScale(.large)
                            .frame(width: 30, height: 30)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .deleteVersionAlert(isPresented: self.$isVersionDeletionAlertPresented,
                            project: self.$project,
                            versionToDeleteIndex: self.versionToDeleteIndex)
    }
}

