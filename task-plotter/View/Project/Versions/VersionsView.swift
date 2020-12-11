//
//  VersionsView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct VersionsView: View {
    @Binding var project: Project
    
    @State var versionCreationOrEditionSheetItem: CreationOrEditionMode? = nil
    @State var versionToEditIndex: Int = 0
    @State var versionToCreateOrEditTempNumber: String = ""
    
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
            
            HStack(spacing: 0) {
                // edit version
                CreateDeleteEditButton(image: Image(systemName: "pencil")) {
                    if let index = self.project.ҩselectedVersionIndex {
                        self.versionToEditIndex = index
                        self.versionToCreateOrEditTempNumber = self.project.ҩselectedVersion?.number ?? ""
                        self.versionCreationOrEditionSheetItem = .edition
                    }
                }
                .disabled(self.project.ҩselectedVersion == nil)
                
                Spacer()
                
                // create version
                CreateDeleteEditButton(image: Image(systemName: "plus")) {
                    self.versionToCreateOrEditTempNumber = ""
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
                VersionCreationModal(project: self.$project,
                                     tempVersionNumber: self.$versionToCreateOrEditTempNumber)
            case .edition:
                VersionEditionModal(project: self.$project,
                                    versionIndex: self.versionToEditIndex,
                                    tempVersionNumber: self.$versionToCreateOrEditTempNumber)
            }
        }
        .deleteVersionAlert(isPresented: self.$isVersionDeletionAlertPresented,
                            project: self.$project,
                            versionToDeleteIndex: self.versionToDeleteIndex)
    }
}

