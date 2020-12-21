//
//  TestRepositories.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

class TestRepositories {
    static let repository: Repository = {
        let labelModel = Label(name: "Model", color: Label.availableColors[41])
        let labelUiUx = Label(name: "UI/UX", color: Label.availableColors[36])
        let labelGraphics = Label(name: "Graphics", color: Label.availableColors[28])
        let labelIO = Label(name: "File I/O", color: Label.availableColors[49])
        let labelScene = Label(name: "Scene", color: Label.availableColors[30])
        let labels = [labelModel, labelUiUx, labelGraphics, labelIO, labelScene]
        
        var tasks = [Column.todo: [Task(title: "Blur and sharpen tools", labelIds: [labelModel.id, labelUiUx.id, labelGraphics.id, labelIO.id, labelScene.id], description: "Tools", cost: 8)],
                     Column.doing: [Task(title: "Site/mail", labelIds: [labelGraphics.id], description: "- Nom de domaine\n- Adresse mail", cost: nil),
                                    Task(title: "In-app purchases", labelIds: [], description: "", cost: 4),
                                    Task(title: "Scene camera", labelIds: [labelUiUx.id], description: "", cost: 2.5),
                                    Task(title: "Cushion effect", labelIds: [labelModel.id, labelUiUx.id, labelGraphics.id], description: "", cost: 1)],
                     Column.done: [Task(title: "User tests", labelIds: [labelModel.id, labelUiUx.id, labelGraphics.id], description: "", cost: 16)]]
        
        tasks[Column.todo]?[0].expectedDueDate = Date() + TimeInterval(60*60*25) // 25 hours after now
        tasks[Column.doing]?[0].expectedDueDate = Date() + TimeInterval(60*60*6) // 6 hours after now
        tasks[Column.doing]?[1].expectedDueDate = Date() - TimeInterval(60*60*5) // 5 hours before now
        tasks[Column.doing]?[2].expectedDueDate = Date() - TimeInterval(60*60*25) // 25 hours before now
        tasks[Column.done]?[0].expectedDueDate = Date() - TimeInterval(60*60*55) // 55 hours before now
        
        var version10 = Version(number: "1.0", pointsPerDay: 4, workingDays: Day.allDays.subtracting([Day.friday]), excludedDates: [])
        let indexedTasks = Dictionary(uniqueKeysWithValues: tasks.map { ($0.key, IndexedArray(elements: $0.value, id: \.id)) })
        version10.tasksByColumn = indexedTasks
        let version11 = Version(number: "1.1")
        
        var project1 = Project(name: "Ardoise", labels: labels)
        project1.versions = [version10, version11]
        project1.selectedVersionId = version10.id
        
        var project2 = Project(name: "Project 2")
        
        let repository = Repository(projects: [project1, project2])
        repository.selectedProjectId = project1.id
        
        return repository
    }()
}
