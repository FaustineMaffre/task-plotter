//
//  DeleteProjectButton.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct DeleteProjectButton: View {
    @ObservedObject var repository: Repository
    
    @State var isProjectDeletionAlertPresented: Bool = false
    
    var body: some View {
        Button {
            self.isProjectDeletionAlertPresented = true
        } label: {
            HStack(spacing: 0) {
                Image(systemName: "minus")
                    .imageScale(.large)
                    .frame(width: 30, height: 30)
                
                Text("Delete the project")
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .alert(isPresented: self.$isProjectDeletionAlertPresented) {
            Alert(title: Text("Delete the project"),
                  message: Text("Are you sure you want to delete project \"\(self.repository.selectedProject?.name ?? "")\"?"),
                  primaryButton: .destructive(Text("Delete"), action: self.delete),
                  secondaryButton: .cancel())
        }
    }
    
    func delete() {
        self.repository.deleteSelectedProject()
    }
}
