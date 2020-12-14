//
//  Repository.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Combine

final class Repository: ObservableObject, Codable {
    
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
    
    var cancellables: Set<AnyCancellable> = []
    
    required init(projects: [Project] = [],
                  selectedProjectId: ProjectID? = nil,
                  saveOnly: Bool = false) {
        self.projects = projects
        self.selectedProjectId = selectedProjectId
        
        self.defaultSelect()
        
        if !saveOnly {
            // save event
            self.$projects.combineLatest(self.$selectedProjectId)
                .sink { newProjects, newSelectedProjectId in
                    Storage.store(Repository(projects: newProjects, selectedProjectId: newSelectedProjectId, saveOnly: true))
                }
                .store(in: &self.cancellables)
        }
    }
    
    func defaultSelect() {
        if self.selectedProjectId == nil && !self.projects.isEmpty {
            self.selectedProjectId = self.projects[0].id
        }
    }
    
    func addProject(_ project: Project, selectIt: Bool) {
        if !project.name.isEmpty {
            self.projects.append(project)
            
            // select it if required
            if selectIt {
                self.selectedProjectId = project.id
            }
        }
    }
    
    func deleteSelectedProject() {
        if let selectedProjectIndex = self.ҩselectedProjectIndex {
            self.projects.remove(at: selectedProjectIndex)
        }
    }
    
    // MARK: - Codable
    enum CodingKeys: CodingKey {
        case projects, selectedProjectId
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let projects = try container.decode([Project].self, forKey: .projects)
        let selectedProjectId = try container.decode(ProjectID?.self, forKey: .selectedProjectId)
        
        self.init(projects: projects, selectedProjectId: selectedProjectId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.projects, forKey: .projects)
        try container.encode(self.selectedProjectId, forKey: .selectedProjectId)
    }
}
