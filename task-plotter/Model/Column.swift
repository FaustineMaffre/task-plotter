//
//  Column.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation

enum Column: String, CaseIterable, Codable {
    case todo = "To do",
         doing = "Doing",
         done = "Done"
}
