//
//  DraggedElement.swift
//  task-plotter
//
//  Created by Faustine Maffre on 17/12/2020.
//

import Foundation

// MARK: - Extension with helper functions

extension Array where Element == Label {
    func find(by id: LabelID) -> Label? {
        self.first { $0.id == id }
    }
}

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
        self.tasksByColumn[column]!.find(by: id)
    }
}

extension Project {
    func findPoolTask(by id: TaskID) -> Task? {
        self.tasksPool.find(by: id)
    }
}

// MARK: - Task list (either a column or the tasks pool)

enum DraggedTaskList {
    case column(_ column: Column),
         pool
    
    func toItemProviderPrefix() -> String {
        switch self {
        case .column(let column): return column.rawValue
        case .pool: return "pool"
        }
    }
    
    static func fromItemProviderPrefix(str: String) -> DraggedTaskList? {
        if let column = Column(rawValue: str) {
            return .column(column)
        } else if str == "pool" {
            return .pool
        } else {
            return nil
        }
    }
    
    func toColumn() -> Column? {
        switch self {
        case .column(let column): return column
        case .pool: return nil
        }
    }
}

// MARK: - Dragged element

enum DraggedElement {
    case label(id: LabelID),
         task(list: DraggedTaskList, id: TaskID)
    
    // MARK: To item provider/string
    
    func elementToItemProvider() -> NSItemProvider {
        let str: String
        
        switch self {
        case .label(let id): str = "label:\(id)"
        case .task(let list, let id): str = "task-\(list.toItemProviderPrefix()):\(id)"
        }
        
        return NSItemProvider(object: str as NSString)
    }
    
    static func toItemProvider(label: Label) -> NSItemProvider {
        DraggedElement.label(id: label.id).elementToItemProvider()
    }
    
    static func toItemProvider(task: Task, column: Column) -> NSItemProvider {
        DraggedElement.task(list: .column(column), id: task.id).elementToItemProvider()
    }
    
    static func toItemProvider(poolTask: Task) -> NSItemProvider {
        DraggedElement.task(list: .pool, id: poolTask.id).elementToItemProvider()
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
                          let dashIndex = prefix.firstIndex(of: "-"),
                          let list = DraggedTaskList.fromItemProviderPrefix(str: String(prefix[prefix.index(after: dashIndex)...])) {
                    res = .task(list: list, id: id)
                }
            }
        }
        
        return res
    }
    
    static func toLabel(itemProvider: NSItemProvider, labels: [Label], completionHandler: @escaping (Label?) -> Void) {
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
    
    static func toTask(itemProvider: NSItemProvider, tasks: [Task], completionHandler: @escaping ((Column, Task)?) -> Void) {
        _ = itemProvider.loadObject(ofClass: String.self) { optionalStr, _ in
            var res: (Column, Task)? = nil
            
            if let str = optionalStr,
               let element = Self.elementFromString(str: str),
               case .task(let list, let taskId) = element,
               let column = list.toColumn(),
               let task = tasks.find(by: taskId) {
                res = (column, task)
            }
            
            completionHandler(res)
        }
    }
    
    static func toTask(itemProvider: NSItemProvider, version: Version, completionHandler: @escaping ((Column, Task)?) -> Void) {
        _ = itemProvider.loadObject(ofClass: String.self) { optionalStr, _ in
            var res: (Column, Task)? = nil
            
            if let str = optionalStr,
               let element = Self.elementFromString(str: str),
               case .task(let list, let taskId) = element,
               case .column(let column) = list,
               let task = version.findTask(in: column, by: taskId) {
                res = (column, task)
            }
            
            completionHandler(res)
        }
    }
    
    static func toPoolTask(itemProvider: NSItemProvider, project: Project, completionHandler: @escaping (Task?) -> Void) {
        _ = itemProvider.loadObject(ofClass: String.self) { optionalStr, _ in
            var res: Task? = nil
            
            if let str = optionalStr,
               let element = Self.elementFromString(str: str),
               case .task(let list, let taskId) = element,
               case .pool = list {
                res = project.findPoolTask(by: taskId)
            }
            
            completionHandler(res)
        }
    }
}
