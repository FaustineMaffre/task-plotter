//
//  TaskView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

struct TaskView: View {
    @State var task: Task
    
    var body: some View {
        HStack {
            Text(self.task.title)
            Spacer()
        }
    }
}
