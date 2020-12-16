//
//  VersionDatesView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 13/12/2020.
//

import SwiftUI

struct VersionDatesView: View {
    @Binding var version: Version
    
    @State var isWorkingDaysPopoverPresented: Bool = false
    @State var isExcludedDatesPopoverPresented: Bool = false
    @State var isDueDatePopoverPresented: Bool = false
    
    @State var selectedForExcludedDates: Date? = nil
    
    static let spaceBetweenItems: CGFloat = 12
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Group {
                    Text("Points per day:")
                    
                    TextField("", text: self.$version.pointsPerDay.stringBinding(formatter: Common.pointsPerDayFormatter))
                        .frame(width: 60)
                }
                
                Spacer().frame(width: Self.spaceBetweenItems)
                
                Group {
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
                
                Spacer().frame(width: Self.spaceBetweenItems)
                
                Group {
                    Text("Working hours:")
                    
                    HStack(spacing: 0) {
                        TextField("", value: self.$version.workingHours.startHour.doubleBinding(), formatter: Common.workingHourFormatter)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 30)
                        Text("-")
                        TextField("", value: self.$version.workingHours.endHour.doubleBinding(), formatter: Common.workingHourFormatter)
                            .multilineTextAlignment(.leading)
                            .frame(width: 30)
                    }
                }
                
                Spacer().frame(width: Self.spaceBetweenItems)
                
                Group {
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
                
                Spacer()
            }
            .disabled(self.version.isValidated)
            
            HStack(spacing: 6) {
                Group {
                    // due date
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
                
                Spacer().frame(width: Self.spaceBetweenItems)
                
                Group {
                    if let pointsStartingNow = self.version.pointsStartingNow,
                       let pointsStartingNowFormatted = Common.pointsStartingNowFormatter.string(from: NSNumber(value: pointsStartingNow)) {
                        // points from now
                        Text("Points from now:")
                        
                        Text(pointsStartingNowFormatted)
                            .frame(height: 22)
                            .padding([.horizontal], 3)
                            .foregroundColor(.black)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.8)))
                        
                        Spacer().frame(width: Self.spaceBetweenItems)
                    } else {
                        EmptyView()
                    }
                }
                
                // compute dates
                Button("Compute tasks dates") {
                    self.version.computeTaskDates()
                }
                .disabled(!self.version.canComputeTaskDates())
                
                // clear dates
                Button("Clear tasks dates") {
                    self.version.clearTaskDates()
                }
                .disabled(!self.version.canClearTaskDates())
                
                Spacer()
            }
            .disabled(self.version.isValidated)
            
            HStack(spacing: 6) {
                Group {
                    if let expectedStartDate = self.version.expectedStartDate {
                        // start date
                        Text("Start date:")
                        
                        DueDateView(dueDate: expectedStartDate, isValidated: self.version.isValidated)
                        
                        Spacer().frame(width: Self.spaceBetweenItems)
                    }
                }
                
                Group {
                    // validate/invalidate version
                    Button("Validate version") {
                        self.version.validate()
                    }
                    .disabled(self.version.isValidated)
                    
                    Button("Cancel validation") {
                        self.version.invalidate()
                    }
                    .disabled(!self.version.isValidated)
                }
                
                Spacer()
            }
        }
        .frame(width: 1096) // same than the three columns
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
