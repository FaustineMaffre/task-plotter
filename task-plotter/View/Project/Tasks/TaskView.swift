//
//  TaskView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

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
    @State var cost: Float?
    
    static let costFormatter: NumberFormatter = {
        var res = NumberFormatter()
        res.numberStyle = .decimal
        return res
    }()
    
    var body: some View {
        if let cost = self.cost,
           let formattedCost = Self.costFormatter.string(from: NSNumber(value: cost)) {
            Text(formattedCost)
                .font(.callout)
                .frame(width: 22, height: 22)
                .foregroundColor(.black)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.8)))
        }
    }
}

struct TaskDueDateView: View {
    @State var column: Column
    @State var dueDate: Date?
    
    var ҩbackgroundColor: Color {
        let now = Date()
        
        guard let dueDate = self.dueDate else {
            return Color.clear
        }
        
        let oneHour = TimeInterval(60*60)
        
        if self.column == .done {
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
        if let dueDate = self.dueDate {
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
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Edit task")
                .font(.headline)
            
            HStack {
                Text("Task title:")
                TextField("", text: self.$tempTaskTitle)
            }
            
            HStack {
                Button("Cancel", action: self.cancel)
                    .keyboardShortcut(.cancelAction)
                
                Button("Edit", action: self.edit)
                    .keyboardShortcut(.defaultAction)
                    .disabled(self.tempTaskTitle.isEmpty)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 300, height: 130)
        .onAppear {
            self.tempTaskTitle = self.task.title
        }
    }
    
    func edit() {
        if !self.tempTaskTitle.isEmpty {
            self.task.title = self.tempTaskTitle
            
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

struct TaskView: View {
    @Binding var task: Task
    
    @State var isTaskEditionSheetPresented: Bool = false
    
    var body: some View {
        HStack {
            VStack(spacing: 4) {
                if !self.task.labels.isEmpty {
                    // TODO new line
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
                    TaskDueDateView(column: task.column, dueDate: self.task.expectedDueDate)
                    Spacer()
                }
            }
            
            Spacer()
            
            TaskCostView(cost: self.task.cost)
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
