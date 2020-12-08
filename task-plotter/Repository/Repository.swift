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
    
    @Published var selectedProjectId: ProjectID? {
        didSet {
            self.defaultSelect()
        }
    }
    
    var ҩselectedProjectIndex: Int? {
        if let selectedProjectId = self.selectedProjectId {
            return self.projects.firstIndex { $0.id == selectedProjectId }
        } else {
            return nil
        }
    }
    
    var ҩselectedProject: Project? {
        if let selectedProjectId = self.selectedProjectId {
            return self.projects.first { $0.id == selectedProjectId }
        } else {
            return nil
        }
    }
    
    required init(labels: [Label], projects: [Project],
                  selectedProjectId: ProjectID? = nil) {
        self.labels = labels
        self.projects = projects
        self.selectedProjectId = selectedProjectId
        
        self.defaultSelect()
    }
    
    func defaultSelect() {
        if self.selectedProjectId == nil && !self.projects.isEmpty {
            self.selectedProjectId = self.projects[0].id
        }
    }
    
    func addProject(name: String, selectIt: Bool) {
        if !name.isEmpty {
            // create new project
            let newProject = Project(name: name)
            self.projects.append(newProject)
            
            // select it if required
            if selectIt {
                self.selectedProjectId = newProject.id
            }
        }
    }
    
    func deleteSelectedProject() {
        if let selectedProjectIndex = self.ҩselectedProjectIndex {
            self.projects.remove(at: selectedProjectIndex)
        }
    }
}
