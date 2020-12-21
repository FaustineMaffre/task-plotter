//
//  DraggedElement.swift
//  task-plotter
//
//  Created by Faustine Maffre on 17/12/2020.
//

import Foundation

// MARK: - Extension with helper functions

extension Project {
    func findLabel(by id: LabelID) -> Label? {
        self.labels.find(by: id)
    }
}

extension Array where Element == Task {
    func find(by id: TaskID) -> Task? {
        self.first { $0.id == id }
    }
}

extension Version {
    func findTask(in column: Column, by id: TaskID) -> Task? {
        self.tasksByColumn[column]?.find(by: id)
    }
}

extension Project {
    func findPoolTask(by id: TaskID) -> Task? {
        self.tasksPool.find(by: id)
    }
}

// MARK: - Dragged element

/// A dragged element in the app (either a label or a task). 
enum DraggedElement {
    case label(id: LabelID),
         task(column: Column?, id: TaskID) // column nil for tasks pool
    
    // MARK: To item provider/string
    
    func elementToItemProvider() -> NSItemProvider {
        let str: String
        
        switch self {
        case .label(let id): str = "label:\(id)"
        case .task(let column, let id): str = "task-\(column?.rawValue ?? "pool"):\(id)"
        }
        
        return NSItemProvider(object: str as NSString)
    }
    
    static func toItemProvider(label: Label) -> NSItemProvider {
        DraggedElement.label(id: label.id).elementToItemProvider()
    }
    
    static func toItemProvider(task: Task, column: Column?) -> NSItemProvider {
        DraggedElement.task(column: column, id: task.id).elementToItemProvider()
    }
    
    // MARK: From item provider/string
    
    static func elementFromString(str: String) -> DraggedElement? {
        var res: DraggedElement? = nil
        
        let split = str.split(separator: ":")
        
        if split.count == 2 {
            let prefix = String(split[0])
            let idStr = String(split[1])
            
            if let id = UUID(uuidString: idStr) {
                if prefix.starts(with: "label") {
                    res = .label(id: id)
                    
                } else if prefix.starts(with: "task-"),
                          let dashIndex = prefix.firstIndex(of: "-") {
                    let columnStr = String(prefix[prefix.index(after: dashIndex)...])
                    let column = Column(rawValue: columnStr) // nil for tasks pool
                    res = .task(column: column, id: id)
                }
            }
        }
        
        return res
    }
    
    static func toLabel(itemProvider: NSItemProvider, labels: IndexedArray<Label, LabelID>, completionHandler: @escaping (Label?) -> Void) {
        _ = itemProvider.loadObject(ofClass: String.self) { optionalStr, _ in
            var res: Label? = nil
            
            if let str = optionalStr,
               let element = Self.elementFromString(str: str),
               case .label(let labelId) = element {
                res = labels.find(by: labelId)
            }
            
            completionHandler(res)
        }
    }
    
    static func toLabel(itemProvider: NSItemProvider, project: Project, completionHandler: @escaping (Label?) -> Void) {
        _ = itemProvider.loadObject(ofClass: String.self) { optionalStr, _ in
            var res: Label? = nil
            
            if let str = optionalStr,
               let element = Self.elementFromString(str: str),
               case .label(let labelId) = element {
                res = project.findLabel(by: labelId)
            }
            
            completionHandler(res)
        }
    }
    
    static func toTask(itemProvider: NSItemProvider, tasks: [Task], completionHandler: @escaping ((Column?, Task)?) -> Void) {
        _ = itemProvider.loadObject(ofClass: String.self) { optionalStr, _ in
            var res: (Column?, Task)? = nil
            
            if let str = optionalStr,
               let element = Self.elementFromString(str: str),
               case .task(let column, let taskId) = element,
               let task = tasks.find(by: taskId) {
                res = (column, task)
            }
            
            completionHandler(res)
        }
    }
    
    static func toTask(itemProvider: NSItemProvider, project: Project, version: Version, completionHandler: @escaping ((Column?, Task)?) -> Void) {
        _ = itemProvider.loadObject(ofClass: String.self) { optionalStr, _ in
            var res: (Column?, Task)? = nil
            
            if let str = optionalStr,
               let element = Self.elementFromString(str: str),
               case .task(let column, let taskId) = element {
                let optionalTask: Task?
                
                if let column = column {
                    optionalTask = version.findTask(in: column, by: taskId)
                } else {
                    // tasks pool
                    optionalTask = project.findPoolTask(by: taskId)
                }
                
                if let task = optionalTask {
                    res = (column, task)
                }
            }
            
            completionHandler(res)
        }
    }
}
