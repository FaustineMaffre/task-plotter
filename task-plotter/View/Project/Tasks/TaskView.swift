//
//  TaskView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

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

struct TaskDueDateView: View {
    @Binding var task: Task
    let column: Column
    
    var ҩbackgroundColor: Color {
        let now = Date()
        
        guard let dueDate = self.task.expectedDueDate else {
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
        if let dueDate = self.task.expectedDueDate {
            Text(Self.dueDateFormatter.string(from: dueDate))
                .padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                .background(RoundedRectangle(cornerRadius: 8).fill(self.ҩbackgroundColor))
        }
    }
}

struct TaskView: View {
    @Binding var task: Task
    let column: Column
    let projectLabels: [Label]
    
    @State var isTaskEditionSheetPresented: Bool = false
    
    var body: some View {
        HStack {
            VStack(spacing: 4) {
                if !self.task.labelIds.isEmpty {
                    // TODO9 wrap
                    HStack(spacing: 3) {
                        ForEach(self.task.labelIds, id: \.self) {
                            if let label = Label.findLabel(id: $0, among: self.projectLabels) {
                                TaskLabelView(label: label)
                            }
                        }
                        
                        Spacer()
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
                    TaskDueDateView(task: self.$task, column: self.column)
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
