//
//  Project.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias ProjectID = UUID

struct Project: Identifiable, Hashable, Equatable {
    let id: ProjectID
    
    var name: String
    var versions: [Version] = []
    
    var selectedVersionIndex: Int? {
        let versions = self.versions
        
        if versions.isEmpty {
            // no version: no selected version
            return nil
        } else {
            if let selectedVersionIndex = versions.firstIndex(where: { $0.id == UserDefaultsConfig.shared.selectedVersionId }) {
                // selected version
                return selectedVersionIndex
            } else {
                // no version selected: select first version
                UserDefaultsConfig.shared.selectedVersionId = versions[0].id
                return 0
            }
        }
    }
    
    var selectedVersion: Version? {
        if let selectedVersionIndex = self.selectedVersionIndex {
            return self.versions[selectedVersionIndex]
        } else {
            return nil
        }
    }
    
    init(id: ProjectID = UUID(),
         name: String) {
        self.id = id
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
}
