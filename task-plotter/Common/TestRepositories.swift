//
//  TestRepositories.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

class TestRepositories {
    static let repository: Repository = {
        let labelModel = Label(name: "Model", color: Color.purple.ҩhex)
        let labelUiUx = Label(name: "UI/UX", color: Color.blue.ҩhex)
        let labelGraphics = Label(name: "Graphics", color: Color.pink.ҩhex)
        let labelIO = Label(name: "File I/O", color: Color.green.ҩhex)
        let labelScene = Label(name: "Scene", color: Color.yellow.ҩhex)
        let labels = [labelModel, labelUiUx, labelGraphics, labelIO, labelScene]
        
        var tasks = [Column.todo: [Task(title: "Blur and sharpen tools", labels: [labelModel, labelUiUx, labelGraphics, labelIO, labelScene], description: "Tools", cost: 8)],
                     Column.doing: [Task(title: "Site/mail", labels: [labelGraphics], description: "- Nom de domaine\n- Adresse mail", cost: nil),
                                    Task(title: "In-app purchases", labels: [], description: "", cost: 4),
                                    Task(title: "Scene camera", labels: [labelUiUx], description: "", cost: 2.5),
                                    Task(title: "Cushion effect", labels: [labelModel, labelUiUx, labelGraphics], description: "", cost: 1)],
                     Column.done: [Task(title: "User tests", labels: [labelModel, labelUiUx, labelGraphics], description: "", cost: 16)]]
        
        tasks[Column.todo]?[0].expectedDueDate = Date() + TimeInterval(60*60*25) // 25 hours after now
        tasks[Column.doing]?[0].expectedDueDate = Date() + TimeInterval(60*60*6) // 6 hours after now
        tasks[Column.doing]?[1].expectedDueDate = Date() - TimeInterval(60*60*5) // 5 hours before now
        tasks[Column.doing]?[2].expectedDueDate = Date() - TimeInterval(60*60*25) // 25 hours before now
        tasks[Column.done]?[0].expectedDueDate = Date() - TimeInterval(60*60*55) // 55 hours before now
        
        var version10 = Version(number: "1.0", pointsPerDay: 4, workingDays: Day.all, excludedDates: [])
        version10.tasksByColumn = tasks
        let version11 = Version(number: "1.1")
        
        var project1 = Project(name: "Ardoise")
        project1.versions = [version10, version11]
        project1.selectedVersionId = version10.id
        
        var project2 = Project(name: "Project 2")
        
        let repository = Repository(labels: labels, projects: [project1, project2])
        repository.selectedProjectId = project1.id
        
        return repository
    }()
}
