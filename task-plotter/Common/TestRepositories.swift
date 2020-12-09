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
        let labels = [labelModel, labelUiUx, labelGraphics]
        
        var tasks = [Task(column: .todo, title: "Blur and sharpen tools", labels: [labelModel, labelUiUx, labelModel, labelUiUx, labelModel, labelUiUx], description: "Tools", cost: 8),
                     Task(column: .doing, title: "Site/mail", labels: [labelGraphics], description: "- Nom de domaine\n- Adresse mail", cost: nil),
                     Task(column: .doing, title: "In-app purchases", labels: [], description: "", cost: 4),
                     Task(column: .doing, title: "Scene camera", labels: [labelUiUx], description: "", cost: 2.5),
                     Task(column: .doing, title: "Cushion effect", labels: [labelModel, labelUiUx, labelGraphics], description: "", cost: 1),
                     Task(column: .done, title: "User tests", labels: [labelModel, labelUiUx, labelGraphics], description: "", cost: 16)]
        
        tasks[0].expectedDueDate = Date() + TimeInterval(60*60*25) // 25 hours after now
        tasks[1].expectedDueDate = Date() + TimeInterval(60*60*6) // 6 hours after now
        tasks[2].expectedDueDate = Date() - TimeInterval(60*60*5) // 5 hours before now
        tasks[3].expectedDueDate = Date() - TimeInterval(60*60*25) // 25 hours before now
        tasks[5].expectedDueDate = Date() - TimeInterval(60*60*55) // 55 hours before now
        
        var version10 = Version(number: "1.0", pointsPerDay: 4, workingDays: Day.all, excludedDates: [])
        version10.tasks = tasks
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
