//
//  VersionsView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

/// List of versions with operations. 
struct VersionsView: View {
    @Binding var project: Project
    
    @State var versionCreationOrEditionSheetItem: CreationOrEditionMode? = nil
    @State var versionToEditIndex: Int = 0
    
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
            List {
                ForEach(self.project.versions.isEmpty ? [-1] : Array(self.project.versions.indices), id: \.self) { versionIndex in
                    if versionIndex < 0 {
                        HStack {
                            Spacer()
                            Text("No version")
                                .foregroundColor(Color.white.opacity(0.2))
                            Spacer()
                        }
                    } else {
                        self.versionView(versionIndex: versionIndex)
                            .listRowInsets(EdgeInsets())
                    }
                }
            }
            
            HStack(spacing: 0) {
                // edit version
                CreateDeleteEditButton(image: Image(systemName: "pencil")) {
                    if let index = self.project.ҩselectedVersionIndex {
                        self.versionToEditIndex = index
                        self.versionCreationOrEditionSheetItem = .edition
                    }
                }
                .disabled(self.project.ҩselectedVersion == nil)
                
                Spacer()
                
                // create version
                CreateDeleteEditButton(image: Image(systemName: "plus")) {
                    self.versionCreationOrEditionSheetItem = .creation
                }
                
                // delete version
                CreateDeleteEditButton(image: Image(systemName: "minus")) {
                    self.versionToDeleteIndex = self.project.ҩselectedVersionIndex
                    self.isVersionDeletionAlertPresented = true
                }
                .disabled(self.project.ҩselectedVersion == nil)
            }
        }
        .sheet(item: self.$versionCreationOrEditionSheetItem) { mode in
            switch mode {
            case .creation:
                VersionCreationModal(project: self.$project)
            case .edition:
                VersionEditionModal(project: self.$project,
                                    versionIndex: self.versionToEditIndex)
            }
        }
        .deleteVersionAlert(isPresented: self.$isVersionDeletionAlertPresented,
                            project: self.$project,
                            versionToDeleteIndex: self.versionToDeleteIndex)
    }
    
    func versionView(versionIndex: Int) -> some View {
        HStack {
            Text(self.project.versions[versionIndex].number)
            Spacer()
        }
        .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
        .background(RoundedRectangle(cornerRadius: 8).fill(self.project.ҩselectedVersionIndex == versionIndex ?
                                                           Color.selectedContentBackgroundColor :
                                                            Color.clear))
        .contentShape(Rectangle())
        .onTapGesture {
            self.project.selectedVersionId = self.project.versions[versionIndex].id
        }
        .contextMenu {
            Button("Delete") {
                self.versionToDeleteIndex = versionIndex
                self.isVersionDeletionAlertPresented = true
            }
        }
    }
}

