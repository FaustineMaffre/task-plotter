//
//  TaskPlotterApp.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

extension NSTableView {
    open override func viewDidMoveToWindow() {
        // remove background from lists
        super.viewDidMoveToWindow()
        
        backgroundColor = .clear
        enclosingScrollView?.drawsBackground = false
    }
}

@main
struct TaskPlotterApp: App {    
    var body: some Scene {
        WindowGroup {
            ContentView(repository: TestRepositories.repository) // TODO8 read from file/document
                .environmentObject(UserDefaultsConfig.shared)
        }
    }
}
