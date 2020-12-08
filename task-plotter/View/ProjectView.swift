//
//  ProjectView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ProjectView: View {
    @ObservedObject var repository: Repository
    
    var body: some View {
        NavigationView {
            // versions on the left
            VersionsView(repository: self.repository)
            
            // tasks on the right
            TasksView(repository: self.repository)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}
