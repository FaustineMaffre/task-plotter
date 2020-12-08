//
//  TasksView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct TasksView: View {
    @ObservedObject var repository: Repository
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tasks")
                    .titleStyle()
                    .padding(10)
                
                Spacer()
            }
            
            if let selectedVersion = self.repository.ҩselectedProject?.ҩselectedVersion {
                List {
                    ForEach(selectedVersion.tasks) { task in
                        Text(task.title)
                    }
                }
            } else {
                Spacer()
            }
        }
    }
}

