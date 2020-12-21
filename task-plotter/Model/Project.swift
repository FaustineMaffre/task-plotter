//
//  Project.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias ProjectID = UUID


/// A project, containing versions.
struct Project: Identifiable, Hashable, Equatable, Codable {
    
    let id: ProjectID
    
    var name: String
    var versions: [Version] = []
    
    /// Labels available in this project.
    var labels: IndexedArray<Label, LabelID> {
        didSet {
            // clean labels of tasks
            // tasks pool
            self.tasksPool.indices.forEach { taskIndex in
                self.tasksPool[taskIndex].cleanLabels(projectLabels: self.labels)
            }
            
            // versions
            self.versions.indices.forEach { versionIndex in
                self.versions[versionIndex].tasksByColumn.keys.forEach { column in
                    self.versions[versionIndex].tasksByColumn[column]?.indices.forEach { taskIndex in
                        self.versions[versionIndex].tasksByColumn[column]?[taskIndex].cleanLabels(projectLabels: self.labels)
                    }
                }
            }
        }
    }
    
    /// ID of the currently selected version, if one is selected.
    var selectedVersionId: VersionID? = nil
    
    /// Index of the currently selected version, if one is selected.
    var ҩselectedVersionIndex: Int? {
        if let selectedVersionId = self.selectedVersionId {
            return self.versions.firstIndex { $0.id == selectedVersionId }
        } else {
            return nil
        }
    }
    
    /// Currently selected version, if one is selected.
    var ҩselectedVersion: Version? {
        if let selectedVersionId = self.selectedVersionId {
            return self.versions.first { $0.id == selectedVersionId }
        } else {
            return nil
        }
    }
    
    /// Pool containing tasks not associated with a version.
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
    
    /// Adds a version, if its number is not empty, and sets it as selected version if required.
    mutating func addVersion(_ version: Version, selectIt: Bool) {
        if !version.number.isEmpty {
            self.versions.append(version)
            
            // select it if required
            if selectIt {
                self.selectedVersionId = version.id
            }
        }
    }
    
    /// Deletes the given version.
    mutating func deleteVersion(version: Version) {
        self.versions.remove(version)
    }
    
    /// Deletes the selected version.
    mutating func deleteSelectedVersion() {
        if let selectedVersionIndex = self.ҩselectedVersionIndex {
            self.versions.remove(at: selectedVersionIndex)
        }
    }
    
    /// Moves the task at the given idnex from the given column of the version at the given index to the end of to do
    /// column of the version at the given index.
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
