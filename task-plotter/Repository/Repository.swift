//
//  Repository.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Combine

class Repository: ObservableObject {
    @Published var labels: [Label]
    
    @Published var projects: [Project]
    
    var selectedProjectIndex: Int? {
        let projects = self.projects
        
        if projects.isEmpty {
            // no project: no selected project
            return nil
        } else {
            if let selectedProjectIndex = projects.firstIndex(where: { $0.id == UserDefaultsConfig.shared.selectedProjectId }) {
                // selected project
                return selectedProjectIndex
            } else {
                // no project selected: select first project
                UserDefaultsConfig.shared.selectedProjectId = projects[0].id
                return 0
            }
        }
    }
    
    var selectedProject: Project? {
        if let selectedProjectIndex = self.selectedProjectIndex {
            return self.projects[selectedProjectIndex]
        } else {
            return nil
        }
    }
    
    required init(labels: [Label], projects: [Project]) {
        self.labels = labels
        self.projects = projects
    }
}
