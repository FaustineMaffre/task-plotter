//
//  CreateTaskButton.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct CreateTaskButton: View {
    @Binding var version: Version
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
                    TextField("", text: self.$tempTaskTitle)
                }
                
                HStack {
                    Button("Cancel", action: self.cancel)
                        .keyboardShortcut(.cancelAction)
                    
                    Button("Create", action: self.create)
                        .keyboardShortcut(.defaultAction)
                        .disabled(self.tempTaskTitle.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 300, height: 130) 
        }
    }
    
    func create() {
        if !self.tempTaskTitle.isEmpty {
            self.version.addTask(column: self.column, title: self.tempTaskTitle)
            
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
