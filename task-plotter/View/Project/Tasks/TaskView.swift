//
//  TaskView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

let costFormatter: NumberFormatter = {
    var res = NumberFormatter()
    res.numberStyle = .decimal
    return res
}()

struct LabelView: View {
    @State var label: Label
    
    var body: some View {
        Text(self.label.name)
            .font(.caption)
            .bold()
            .frame(height: 12)
            .padding(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 8))
            .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: self.label.color)))
    }
}

struct TaskCostView: View {
    @Binding var task: Task
    
    var body: some View {
        if let cost = self.task.cost,
           let formattedCost = costFormatter.string(from: NSNumber(value: cost)) {
            Text(formattedCost)
                .font(.callout)
                .frame(width: 22, height: 22)
                .foregroundColor(.black)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.8)))
        }
    }
}

struct TaskDueDateView: View {
    @Binding var task: Task
    
    var ҩbackgroundColor: Color {
        let now = Date()
        
        guard let dueDate = self.task.expectedDueDate else {
            return Color.clear
        }
        
        let oneHour = TimeInterval(60*60)
        
        if self.task.column == .done {
            // done
            return Color.green.opacity(0.5)
            
        } else if now <= dueDate - 24 * oneHour {
            // due in more than 24 hours
            return Color.black.opacity(0.2)
            
        } else if dueDate - 24 * oneHour < now && now <= dueDate {
            // due in less than 24 hours
            return Color.orange.opacity(0.5)
            
        } else if dueDate < now && now <= dueDate + 24 * oneHour {
            // due since less than 24 hours
            return Color.red.opacity(0.5)
        } else {
            // due since more than 24 hours
            return Color.red.opacity(0.25)
        }
    }
    
    static let dueDateFormatter: DateFormatter = {
        var res = DateFormatter()
        res.dateStyle = .short
        res.timeStyle = .short
        return res
    }()
    
    var body: some View {
        if let dueDate = self.task.expectedDueDate {
            Text(Self.dueDateFormatter.string(from: dueDate))
                .padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                .background(RoundedRectangle(cornerRadius: 8).fill(self.ҩbackgroundColor))
        }
    }
}

struct TaskEditionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var task: Task
    
    @State var tempTaskTitle: String = ""
    @State var tempTaskDescription: String = ""
    
    @State var tempTaskCost: Float? = nil
    
    static let labelsWidth: CGFloat = 80
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Edit task")
                .font(.headline)
            
            Spacer()
                .frame(height: 20)
            
            VStack(spacing: 6) {
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
                }
                
                // TODO labels
                
                HStack(spacing: 20) {
                    Text("Estimated cost")
                        .frame(width: Self.labelsWidth, alignment: .leading)
                    TextField("", value: self.$tempTaskCost, formatter: costFormatter)
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
        .frame(width: 400, height: 300)
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

// TODO show icon when description non-empty

struct TaskView: View {
    @Binding var task: Task
    
    @State var isTaskEditionSheetPresented: Bool = false
    
    var body: some View {
        HStack {
            VStack(spacing: 4) {
                if !self.task.labels.isEmpty {
                    // TODO wrap
                    HStack(spacing: 3) {
                        ForEach(self.task.labels, id: \.name) {
                            LabelView(label: $0)
                        }
                        
                        Spacer()
                    }
                }
                
                HStack {
                    Text(self.task.title)
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 2)
                
                HStack {
                    TaskDueDateView(task: self.$task)
                    Spacer()
                }
            }
            
            Spacer()
            
            TaskCostView(task: self.$task)
        }
        .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
        .frame(width: 280)
        .background(RoundedRectangle(cornerRadius: 8)
                        .fillAndStroke(fill: Color(NSColor.windowBackgroundColor),
                                       stroke: Color.white.opacity(0.1)))
        .onTapGesture(count: 2) {
            self.isTaskEditionSheetPresented = true
        }
        .sheet(isPresented: self.$isTaskEditionSheetPresented) {
            TaskEditionView(task: self.$task)
        }
    }
}
