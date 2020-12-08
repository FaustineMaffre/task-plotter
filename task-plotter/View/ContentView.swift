//
//  ContentView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userDefaults: UserDefaultsConfig
    @ObservedObject var repository: Repository
    
    var body: some View {
        if self.repository.selectedProject != nil {
            VStack(spacing: 0) {
                ProjectMenu(repository: self.repository)
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                
                Divider()
                
                ProjectView(repository: self.repository)
            }
        } else {
            // no projects
            EmptyProjectsView(repository: self.repository)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repository: TestRepositories.repository)
            .environmentObject(UserDefaultsConfig.shared)
            .previewLayout(.fixed(width: 800, height: 600))
    }
}
