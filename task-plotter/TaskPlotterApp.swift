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
    let repository: Repository
    
    init() {
        if let repository = Storage.retrieve(as: Repository.self) {
            self.repository = repository
        } else {
            self.repository = Repository()
        }
    }
    
    var body: some Scene {
        WindowGroup {
//            ContentView(repository: TestRepositories.repository) // TODOt
            ContentView(repository: self.repository)
                .environmentObject(UserDefaultsConfig.shared)
        }
    }
}
