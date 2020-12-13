//
//  VersionDatesView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 13/12/2020.
//

import SwiftUI

// TODO7 compute dates per task

struct VersionDatesView: View {
    @Binding var version: Version
    
    @State var isWorkingDaysPopoverPresented: Bool = false
    @State var isExcludedDatesPopoverPresented: Bool = false
    @State var isDueDatePopoverPresented: Bool = false
    
    @State var selectedForExcludedDates: Date? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            Spacer()
            
            // points per day
            HStack {
                Text("Points per day:")
                TextField("", text: self.$version.pointsPerDay.stringBinding(formatter: Common.pointsPerDayFormatter))
                    .frame(width: 60)
            }
            
            // working days
            HStack {
                Text("Working days:")
                Button {
                    self.isWorkingDaysPopoverPresented = true
                } label: {
                    Text(self.version.formattedWorkingDays(emptyDaysText: "None"))
                }
                .popover(isPresented: self.$isWorkingDaysPopoverPresented) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Day.allCases, id: \.self) { day in
                            Toggle(day.rawValue, isOn: self.generateWorkingDaysBinding(day: day))
                        }
                    }
                    .padding(10)
                }
            }
            
            // excluded dates
            HStack {
                Text("Excluded dates:")
                
                HStack(spacing: 0) {
                    // add/remove
                    Button {
                        self.isExcludedDatesPopoverPresented = true
                    } label: {
                        Text(self.version.formattedExcludedDates(emptyDaysText: "None"))
                    }
                    .popover(isPresented: self.$isExcludedDatesPopoverPresented) {
                        VStack(spacing: 6) {
                            DatePicker("", selection: self.generateSelectedForExcludedDatesBinding(), displayedComponents: [.date])
                                .labelsHidden()
                                .datePickerStyle(GraphicalDatePickerStyle())
                            
                            HStack {
                                Button {
                                    if let selectedDate = self.selectedForExcludedDates {
                                        self.version.excludedDates.insert(selectedDate)
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .frame(width: 20, height: 20)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button {
                                    if let selectedDate = self.selectedForExcludedDates {
                                        self.version.excludedDates.remove(selectedDate)
                                    }
                                } label: {
                                    Image(systemName: "minus")
                                        .frame(width: 20, height: 20)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(10)
                    }
                    
                    // clear
                    Button {
                        self.version.excludedDates.removeAll()
                    } label: {
                        Image(systemName: "multiply")
                            .frame(width: 16, height: 16)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // due date
            HStack {
                Text("Due date:")
                
                HStack(spacing: 0) {
                    // set
                    Button {
                        self.isDueDatePopoverPresented = true
                    } label: {
                        if let dueDate = self.version.dueDate {
                            Text(Common.dueDateFormatter.string(from: dueDate))
                        } else {
                            Text("None")
                        }
                    }
                    .popover(isPresented: self.$isDueDatePopoverPresented) {
                        DatePicker("", selection: self.generateDueDateBinding(), displayedComponents: [.date])
                            .labelsHidden()
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(10)
                    }
                    
                    // clear
                    Button {
                        self.version.dueDate = nil
                    } label: {
                        Image(systemName: "multiply")
                            .frame(width: 16, height: 16)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    func generateWorkingDaysBinding(day: Day) -> Binding<Bool> {
        Binding {
            self.version.workingDays.contains(day)
        } set: {
            if $0 {
                self.version.workingDays.insert(day)
            } else {
                self.version.workingDays.remove(day)
            }
        }
    }
    
    func generateSelectedForExcludedDatesBinding() -> Binding<Date> {
        Binding<Date> {
            self.selectedForExcludedDates ?? Date()
        } set: { newDate in
            self.selectedForExcludedDates = newDate
        }
    }
    
    func generateDueDateBinding() -> Binding<Date> {
        Binding<Date> {
            self.version.dueDate ?? Date()
        } set: { newDate in
            self.version.dueDate = newDate
        }
    }
}
