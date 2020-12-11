//
//  Collection+.swift
//  task-plotter
//
//  Created by Faustine Maffre on 09/12/2020.
//

import Foundation

extension Array where Element: Equatable {
    func substracting(other: Array<Self.Element>) -> Array<Self.Element> {
        self.filter { !other.contains($0) }
    }
    
    mutating func remove(_ element: Self.Element) {
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
        }
    }
    
    @discardableResult
    mutating func remove<Property: Equatable>(_ elementProperty: Property, by propertyPath: KeyPath<Self.Element, Property>) -> Self.Element? {
        let res: Self.Element?
        
        if let index = self.firstIndex(where: { $0[keyPath: propertyPath] == elementProperty }) {
            res = self.remove(at: index)
        } else {
            res = nil
        }
        
        return res
    }
}
