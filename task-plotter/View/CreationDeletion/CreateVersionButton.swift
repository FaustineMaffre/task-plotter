//
//  CreateVersionButton.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct CreateVersionButton: View {
    @ObservedObject var repository: Repository
    
    @State var isVersionCreationSheetPresented: Bool = false
    @State var tempVersionNumber: String = ""
    
    let showText: Bool
    
    var body: some View {
        Button {
            self.isVersionCreationSheetPresented = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(width: 30, height: 30)
                
                if self.showText {
                    Text("Add a version")
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: self.$isVersionCreationSheetPresented) {
            VStack(spacing: 20) {
                Spacer()
                
                Text("Add a new version")
                    .font(.headline)
                
                HStack {
                    Text("Version number:")
                    TextField("", text: self.$tempVersionNumber)
                }
                
                HStack {
                    Button("Cancel", action: self.cancel)
                        .keyboardShortcut(.cancelAction)
                    
                    Button("Create", action: self.create)
                        .keyboardShortcut(.defaultAction)
                        .disabled(self.tempVersionNumber.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 300, height: 130)
        }
    }
    
    func create() {
        if !self.tempVersionNumber.isEmpty,
           let selectedProjectIndex = self.repository.ҩselectedProjectIndex {
            self.repository.projects[selectedProjectIndex].addVersion(number: self.tempVersionNumber, selectIt: true)
            
            // close sheet and reset text
            self.isVersionCreationSheetPresented = false
            self.tempVersionNumber = ""
        }
    }
    
    func cancel() {
        // close sheet and reset text
        self.isVersionCreationSheetPresented = false
        self.tempVersionNumber = ""
    }
}
