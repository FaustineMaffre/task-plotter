//
//  DeletionAlerts.swift
//  task-plotter
//
//  Created by Faustine Maffre on 11/12/2020.
//

import SwiftUI

extension View {
    func deleteVersionAlert(isPresented: Binding<Bool>, project: Binding<Project>, versionToDeleteIndex: Int?) -> some View {
        let versionNumber: String
        if let index = versionToDeleteIndex {
            versionNumber = project.wrappedValue.versions[index].number
        } else {
            versionNumber = ""
        }
        
        let deleteAction: () -> Void = {
            if let index = versionToDeleteIndex {
                project.versions.wrappedValue.remove(at: index)
            }
        }
        
        return self
            .alert(isPresented: isPresented) {
                Alert(title: Text("Delete the version"),
                      message: Text("Are you sure you want to delete version \"\(versionNumber)\"?"),
                      primaryButton: .destructive(Text("Delete"), action: deleteAction),
                      secondaryButton: .cancel())
            }
    }
}
