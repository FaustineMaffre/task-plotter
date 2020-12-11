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
    
    var selectedVersionId: VersionID?
    
    var ҩselectedVersionIndex: Int? {
        if let selectedVersionId = self.selectedVersionId {
            return self.versions.firstIndex { $0.id == selectedVersionId }
        } else {
            return nil
        }
    }
    
    var ҩselectedVersion: Version? {
        if let selectedVersionId = self.selectedVersionId {
            return self.versions.first { $0.id == selectedVersionId }
        } else {
            return nil
        }
    }
    
    init(id: ProjectID = UUID(),
         name: String,
         selectedVersionId: VersionID? = nil) {
        self.id = id
        self.name = name
        self.selectedVersionId = selectedVersionId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
    
    mutating func addVersion(number: String, selectIt: Bool) {
        if !number.isEmpty {
            // create new version
            let newVersion = Version(number: number)
            self.versions.append(newVersion)
            
            // select it if required
            if selectIt {
                self.selectedVersionId = newVersion.id
            }
        }
    }
    
    mutating func deleteVersion(version: Version) {
        self.versions.remove(version)
    }
    
    mutating func deleteSelectedVersion() {
        if let selectedVersionIndex = self.ҩselectedVersionIndex {
            self.versions.remove(at: selectedVersionIndex)
        }
    }
}
