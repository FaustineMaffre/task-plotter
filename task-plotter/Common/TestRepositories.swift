//
//  TestRepositories.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

class TestRepositories {
    static let repository: Repository = {
        let labelModel = Label(name: "Model", color: Color.purple.description)
        let labelUiUx = Label(name: "UI/UX", color: Color.blue.description)
        let labelGraphics = Label(name: "Graphics", color: Color.pink.description)
        let labels = [labelModel, labelUiUx, labelGraphics]
        
        let tasks = [Task(column: .todo, title: "Blur and sharpen tools", labels: [labelModel, labelUiUx], description: "Tools", cost: 8),
                     Task(column: .doing, title: "Site/mail", labels: [labelGraphics], description: "- Nom de domaine\n- Adresse mail", cost: nil),
                     Task(column: .done, title: "In-app purchases", labels: [], description: "", cost: 4),
                     Task(column: .done, title: "Scene camera", labels: [labelUiUx], description: "", cost: 2),
                     Task(column: .done, title: "Cushion effect", labels: [labelModel, labelUiUx, labelGraphics], description: "", cost: 1)]
        
        var version = Version(number: "1.0", pointsPerDay: 4, workingDays: Day.all, excludedDates: [])
        version.tasks = tasks
        
        var project = Project(name: "Ardoise")
        project.versions = [version]
        
        return Repository(labels: labels, projects: [])
    }()
}
