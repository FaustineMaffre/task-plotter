//
//  TaskPlotterApp.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

@main
struct TaskPlotterApp: App {    
    var body: some Scene {
        WindowGroup {
            ContentView(repository: Repository(labels: [], projects: [])) // TODO read from file/document
                .environmentObject(UserDefaultsConfig.shared)
        }
    }
}
