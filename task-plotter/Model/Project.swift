//
//  Project.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias ProjectID = UUID

struct Project: Identifiable, Hashable, Equatable, Codable {
    
    let id: ProjectID
    
    var name: String
    var versions: [Version] = []
    
    var labels: [Label]
    
    var selectedVersionId: VersionID? = nil
    
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
         labels: [Label]) {
        self.id = id
        self.name = name
        self.labels = labels
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
    
    mutating func addVersion(_ version: Version, selectIt: Bool) {
        if !version.number.isEmpty {
            self.versions.append(version)
            
            // select it if required
            if selectIt {
                self.selectedVersionId = version.id
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
    
    mutating func moveTaskTo(taskCurrentVersionIndex: Int, taskCurrentColumn: Column, taskIndex: Int, destinationVersionIndex: Int) {
        let task = self.versions[taskCurrentVersionIndex].tasksByColumn[taskCurrentColumn]!.remove(at: taskIndex)
        self.versions[destinationVersionIndex].addTask(column: .todo, task)
    }
}
