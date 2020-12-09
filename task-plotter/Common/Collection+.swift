//
//  Collection+.swift
//  task-plotter
//
//  Created by Faustine Maffre on 09/12/2020.
//

import Foundation

extension Array where Element: Equatable {
    func substracting(other: Array<Self.Element>) -> Array<Self.Element> {
        return self.filter { !other.contains($0) }
    }
}
