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
    
    var selectedProject: Project? {
        let projects = self.projects
        
        if projects.isEmpty {
            // no project: no selected project
            return nil
        } else {
            if let selectedProject = projects.first(where: { $0.id == UserDefaultsConfig.shared.selectedProjectId }) {
                // selected project
                return selectedProject
            } else {
                // no project selected: select first project
                UserDefaultsConfig.shared.selectedProjectId = projects[0].id
                return projects[0]
            }
        }
    }
    
    required init(labels: [Label], projects: [Project]) {
        self.labels = labels
        self.projects = projects
    }
}
