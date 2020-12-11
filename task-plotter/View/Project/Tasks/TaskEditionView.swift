//
//  TaskEditionView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 09/12/2020.
//

import SwiftUI
import UniformTypeIdentifiers

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
    @Binding var selectedLabels: [Label]
    let allLabels: [Label]
    
    var ҩavailableLabels: [Label] {
        self.allLabels.substracting(other: self.selectedLabels)
    }
    
    @State var isDropTargeted: Bool = false

    static let emptyLabel: Label = Label(name: "", color: Color.clear.ҩhex)
    static let spacingBetweenLists: CGFloat = 8
    
    var body: some View {
        HStack {
            // available
            self.labelsListView(title: "Available", labels: self.ҩavailableLabels, onDrop: { labelName, _ in self.removeLabel(withName: labelName) })
            
            // added
            self.labelsListView(title: "Selected", labels: self.selectedLabels, onDrop: self.addLabel)
        }
    }
    
    func addLabel(withName name: String, at index: Int) {
        DispatchQueue.main.async {
            if let availableLabel = self.ҩavailableLabels.first(where: { $0.name == name }) {
                // inserting available label
                if self.selectedLabels.isEmpty {
                    // in case index would be outside bounds (because of empty labels)
                    self.selectedLabels.append(availableLabel)
                } else {
                    self.selectedLabels.insert(availableLabel, at: index)
                }
            } else if let taskLabelIndex = self.selectedLabels.firstIndex(where: { $0.name == name }) {
                // label not available, we are moving a label in the same list
                self.selectedLabels.move(fromOffsets: IndexSet(arrayLiteral: taskLabelIndex), toOffset: index)
            }
        }
    }
    
    func removeLabel(withName name: String) {
        DispatchQueue.main.async {
            if let labelIndex = self.selectedLabels.firstIndex(where: { $0.name == name }) {
                self.selectedLabels.remove(at: labelIndex)
            }
        }
    }
    
    func labelsListView(title: String, labels: [Label], onDrop: @escaping (String, Int) -> Void) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .bold()
            
            List {
                ForEach(labels.isEmpty ? [Self.emptyLabel] : labels, id: \.self) { label in
                    if label == Self.emptyLabel {
                        HStack {
                            Spacer()
                            Text("No label")
                                .foregroundColor(Color.white.opacity(0.2))
                            Spacer()
                        }
                    } else {
                        HStack {
                            Spacer()
                            TaskLabelSelectorLabelView(label: label)
                            Spacer()
                        }
                        .frame(height: 30)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .onDrag { NSItemProvider(object: label.name as NSString) }
                    }
                }
                .onInsert(of: [UTType.plainText]) { index, items in
                    items.forEach { item in
                        _ = item.loadObject(ofClass: String.self) { str, _ in
                            if let labelName = str {
                                onDrop(labelName, index)
                            }
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
    @State var tempTaskLabels: [Label] = []
    @State var tempTaskDescription: String = ""
    @State var tempTaskCost: Double? = nil
    
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
                    TaskLabelSelector(selectedLabels: self.$tempTaskLabels, allLabels: self.labels)
                }
                
                // TODOq0 cost not saved when tapping button (but ok with enter)
                HStack(spacing: 20) {
                    Text("Estimated cost")
                        .frame(width: Self.labelsWidth, alignment: .leading)
                    TextField("", value: self.$tempTaskCost, formatter: Common.costFormatter)
                }
            }
            
            Spacer()
                .frame(height: 20)
            
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
            self.tempTaskLabels = self.task.labels
            self.tempTaskDescription = self.task.description
            self.tempTaskCost = self.task.cost
        }
    }
    
    func edit() {
        if !self.tempTaskTitle.isEmpty {
            self.task.title = self.tempTaskTitle
            self.task.labels = self.tempTaskLabels
            self.task.description = self.tempTaskDescription
            self.task.cost = self.tempTaskCost
            
            // close sheet and reset text
            self.presentationMode.wrappedValue.dismiss()
            self.tempTaskTitle = ""
            self.tempTaskLabels = []
            self.tempTaskDescription = ""
            self.tempTaskCost = nil
        }
    }
    
    func cancel() {
        // close sheet and reset text
        self.presentationMode.wrappedValue.dismiss()
        self.tempTaskTitle = ""
        self.tempTaskLabels = []
        self.tempTaskDescription = ""
        self.tempTaskCost = nil
    }
}
