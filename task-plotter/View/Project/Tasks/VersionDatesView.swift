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
    
    var body: some View {
        HStack {
            Spacer()
            
            // points per day
            Text("Points per day:")
            TextField("", text: self.$version.pointsPerDay.stringBinding(formatter: Common.pointsPerDayFormatter))
                .frame(width: 60)
            
            // working days
            Text("Working days:")
            Button {
                self.isWorkingDaysPopoverPresented = true
            } label: {
                Text(self.version.formattedWorkingDays())
            }
            .popover(isPresented: self.$isWorkingDaysPopoverPresented) {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Day.allCases, id: \.self) { day in
                        Toggle(day.rawValue, isOn: self.generateWorkingDaysBinding(day: day))
                    }
                }
                .padding(10)
            }
            
            // TODOq excluded dates
            // TODOq due date
        }
    }
    
    func generateWorkingDaysBinding(day: Day) -> Binding<Bool> {
        Binding {
            self.version.workingDays.contains(day)
        } set: {
            if $0 {
                self.version.workingDays.append(day)
            } else {
                self.version.workingDays.remove(day)
            }
        }
    }
}
