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
    
    var labels: IndexedArray<Label, LabelID>
    
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
    
    var tasksPool: IndexedArray<Task, TaskID>
    
    init(id: ProjectID = UUID(), name: String, labels: [Label] = [], tasksPool: [Task] = []) {
        
        self.id = id
        self.name = name
        self.labels = IndexedArray<Label, LabelID>(elements: labels, id: \.id)
        self.tasksPool = IndexedArray<Task, TaskID>(elements: tasksPool, id: \.id)
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
        if let task = self.versions[taskCurrentVersionIndex].tasksByColumn[taskCurrentColumn]?.remove(at: taskIndex) {
            self.versions[destinationVersionIndex].tasksByColumn[.todo]?.append(task)
        }
    }
    
    // MARK: - Codable
    
    enum CodingKeys: CodingKey {
        case id,
             name, versions,
             labels,
             selectedVersionId,
             tasksPool, tasksPoolVisibleLabelIds, tasksPoolOrdering
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(ProjectID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let versions = try container.decode([Version].self, forKey: .versions)
        let labels = try container.decode([Label].self, forKey: .labels)
        let selectedVersionId = try container.decode(VersionID?.self, forKey: .selectedVersionId)
        let tasksPool = try container.decode([Task].self, forKey: .tasksPool)
        
        self.init(id: id, name: name, labels: labels, tasksPool: tasksPool)
        self.versions = versions
        self.selectedVersionId = selectedVersionId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.versions, forKey: .versions)
        try container.encode(self.labels.elements, forKey: .labels)
        try container.encode(self.selectedVersionId, forKey: .selectedVersionId)
        try container.encode(self.tasksPool.elements, forKey: .tasksPool)
    }
}
