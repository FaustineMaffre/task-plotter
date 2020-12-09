//
//  TaskEditionView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 09/12/2020.
//

import SwiftUI

struct TaskLabelSelectorLabelView: View {
    @State var label: Label
    
    var body: some View {
        Text(self.label.name)
            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
            .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: self.label.color)))
    }
}

struct TaskLabelSelector: View {
    // TODOq move labels
    
    @Binding var task: Task
    let labels: [Label]
    
    var ҩavailableLabels: [Label] {
        self.labels.substracting(other: self.task.labels)
    }

    static let spacingBetweenLists: CGFloat = 8
    
    var body: some View {
        HStack {
            // available
            self.labelsListView(title: "Available", labels: self.ҩavailableLabels)
            
            // added
            self.labelsListView(title: "Selected", labels: self.task.labels)
        }
    }
    
    func labelsListView(title: String, labels: [Label]) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .bold()
            
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(labels, id: \.self) { label in
                        HStack {
                            Spacer()
                            TaskLabelSelectorLabelView(label: label)
                            Spacer()
                        }
                    }
                }
            }
            .border(Color.white.opacity(0.1))
            .background(Color(NSColor.controlBackgroundColor))
        }
    }
}

struct TaskEditionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var task: Task
    let labels: [Label]
    
    @State var tempTaskTitle: String = ""
    @State var tempTaskDescription: String = ""
    
    @State var tempTaskCost: Float? = nil
    
    static let labelsWidth: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Edit task")
                .font(.headline)
            
            Spacer()
                .frame(height: 20)
            
            VStack(spacing: 10) {
                HStack(spacing: 20) {
                    Text("Title")
                        .frame(width: Self.labelsWidth, alignment: .leading)
                    TextField("", text: self.$tempTaskTitle)
                }
                
                HStack(alignment: .top, spacing: 20) {
                    Text("Description")
                        .frame(width: Self.labelsWidth, alignment: .leading)
                    TextEditor(text: self.$tempTaskDescription)
                        .font(.body)
                        .border(Color.white.opacity(0.1))
                }
                
                HStack(alignment: .top, spacing: 20) {
                    Text("Labels")
                        .frame(width: Self.labelsWidth, alignment: .leading)
                    TaskLabelSelector(task: self.$task, labels: self.labels)
                }
                
                HStack(spacing: 20) {
                    Text("Estimated cost")
                        .frame(width: Self.labelsWidth, alignment: .leading)
                    TextField("", value: self.$tempTaskCost, formatter: Common.costFormatter)
                }
            }
            
            Spacer()
            
            HStack {
                Button("Cancel", action: self.cancel)
                    .keyboardShortcut(.cancelAction)
                
                Button("Edit", action: self.edit)
                    .keyboardShortcut(.defaultAction)
                    .disabled(self.tempTaskTitle.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 600)
        .onAppear {
            self.tempTaskTitle = self.task.title
            self.tempTaskDescription = self.task.description
            self.tempTaskCost = self.task.cost
        }
    }
    
    func edit() {
        if !self.tempTaskTitle.isEmpty {
            self.task.title = self.tempTaskTitle
            self.task.description = self.tempTaskDescription
            self.task.cost = self.tempTaskCost
            
            // close sheet and reset text
            self.presentationMode.wrappedValue.dismiss()
            self.tempTaskTitle = ""
        }
    }
    
    func cancel() {
        // close sheet and reset text
        self.presentationMode.wrappedValue.dismiss()
        self.tempTaskTitle = ""
    }
}
