//
//  TaskView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

/// View of the label of a task. 
struct TaskLabelView: View {
    let label: Label
    
    var body: some View {
        Text(self.label.name)
            .font(.caption)
            .bold()
            .frame(height: 12)
            .foregroundColor(Label.foregroundOn(background: self.label.color))
            .padding(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 8))
            .background(RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: self.label.color)))
    }
}

/// View of the cost of a task.
struct TaskCostView: View {
    @Binding var task: Task
    
    var body: some View {
        if let cost = self.task.cost,
           let formattedCost = Common.costFormatter.string(from: NSNumber(value: cost)) {
            Text(formattedCost)
                .font(.callout)
                .frame(width: 22, height: 22)
                .foregroundColor(.black)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.8)))
        }
    }
}

/// View of a due date, with a background depending on the current date.
struct DueDateView: View {
    let dueDate: Date?
    
    /// True if the date should be considered as validated.
    let isValidated: Bool
    
    var ҩbackgroundColor: Color {
        let now = Date()
        
        guard let dueDate = self.dueDate else {
            return Color.clear
        }
        
        if self.isValidated {
            // done
            return Color.green.opacity(0.5)
            
        } else if now <= dueDate.substractingOneDay() {
            // due in more than 24 hours
            return Color.black.opacity(0.2)
            
        } else if dueDate.substractingOneDay() < now && now <= dueDate {
            // due in less than 24 hours
            return Color.orange.opacity(0.5)
            
        } else if dueDate < now && now <= dueDate.addingOneDay() {
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

/// A view of one task.
struct TaskView: View {
    @Binding var task: Task
    let isValidated: Bool
    
    let projectLabels: IndexedArray<Label, LabelID>
    
    @State var isTaskEditionSheetPresented: Bool = false
    
    var body: some View {
        // TODOq0 clean those somewhere (at start?)
        let deletedLabels = self.task.labelIds.filter { self.projectLabels.find(by: $0) == nil }
        if !deletedLabels.isEmpty {
            print("Task \(self.task.title): \(deletedLabels.count) deleted label(s)")
        }
        
        return HStack {
            VStack(spacing: 4) {
                if !self.task.labelIds.isEmpty {
                    HStackWrap(elements: self.task.labelIds, horizontalSpacing: 3, verticalSpacing: 2) { _, labelId in
                        Group {
                            if let label = self.projectLabels.find(by: labelId) {
                                TaskLabelView(label: label)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
                
                HStack {
                    Text(self.task.title)
                    Spacer()
                }
                
                HStack {
                    if !self.task.description.isEmpty {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                Spacer()
                    .frame(height: 2)
                
                HStack {
                    DueDateView(dueDate: self.task.expectedDueDate, isValidated: self.isValidated)
                    Spacer()
                }
            }
            
            Spacer()
            
            TaskCostView(task: self.$task)
        }
        .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
        .background(RoundedRectangle(cornerRadius: 8)
                        .fillAndStroke(fill: Color(NSColor.windowBackgroundColor),
                                       stroke: Color.white.opacity(0.1)))
    }
}
