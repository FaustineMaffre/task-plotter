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
    
    required init(labels: [Label], projects: [Project]) {
        self.labels = labels
        self.projects = projects
    }
}
