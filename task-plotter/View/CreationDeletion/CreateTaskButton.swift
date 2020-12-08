//
//  CreateTaskButton.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct CreateTaskButton: View {
    @ObservedObject var repository: Repository
    
    let column: Column
    
    @State var isTaskCreationSheetPresented: Bool = false
    @State var tempTaskTitle: String = ""
    
    let showText: Bool
    
    var body: some View {
        Button {
            self.isTaskCreationSheetPresented = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .frame(width: 30, height: 30)
                
                if self.showText {
                    Text("Add a task")
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: self.$isTaskCreationSheetPresented) {
            VStack(spacing: 20) {
                Spacer()
                
                Text("Add a new task")
                    .font(.headline)
                
                HStack {
                    Text("Task title:")
                    TextField("", text: self.$tempTaskTitle, onCommit: self.create)
                }
                
                HStack {
                    Button("Cancel", action: self.cancel)
                    
                    Button("Create", action: self.create)
                        .disabled(self.tempTaskTitle.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 300, height: 130) 
        }
    }
    
    func create() {
        if !self.tempTaskTitle.isEmpty,
           let selectedProjectIndex = self.repository.ҩselectedProjectIndex,
           let selectedVersionIndex = self.repository.projects[selectedProjectIndex].ҩselectedVersionIndex {
            self.repository.projects[selectedProjectIndex].versions[selectedVersionIndex].addTask(column: self.column, title: self.tempTaskTitle)
            
            // close sheet and reset text
            self.isTaskCreationSheetPresented = false
            self.tempTaskTitle = ""
        }
    }
    
    func cancel() {
        // close sheet and reset text
        self.isTaskCreationSheetPresented = false
        self.tempTaskTitle = ""
    }
}
