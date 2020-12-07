//
//  Project.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

typealias ProjectID = UUID

struct Project: Identifiable {
    let id: ProjectID
    
    var name: String
    var versions: [Version] = []
    
    init(id: ProjectID = UUID(),
         name: String) {
        self.id = id
        self.name = name
    }
}
