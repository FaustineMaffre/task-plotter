//
//  DeleteVersionButton.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct DeleteVersionButton: View {
    @ObservedObject var repository: Repository
    
    @State var isVersionDeletionAlertPresented: Bool = false
    
    let showText: Bool
    
    var body: some View {
        Button {
            self.isVersionDeletionAlertPresented = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "minus")
                    .imageScale(.large)
                    .frame(width: 30, height: 30)
                
                if self.showText {
                    Text("Delete the version")
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .alert(isPresented: self.$isVersionDeletionAlertPresented) {
            Alert(title: Text("Delete the version"),
                  message: Text("Are you sure you want to delete version \"\(self.repository.ҩselectedProject?.ҩselectedVersion?.number ?? "")\"?"),
                  primaryButton: .destructive(Text("Delete"), action: self.delete),
                  secondaryButton: .cancel())
        }
    }
    
    func delete() {
        if let selectedProjectIndex = self.repository.ҩselectedProjectIndex {
            self.repository.projects[selectedProjectIndex].deleteSelectedVersion()
        }
    }
}
