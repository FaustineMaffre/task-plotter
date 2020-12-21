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

extension Set where Element == Date {
    /// Return a list of ranges of dates, sorted, such that consecutive days are grouped in the same range.
    func toRangesOfDays() -> [ClosedRange<Date>] {
        var res = [ClosedRange<Date>]()
        
        if !self.isEmpty {
            let sortedDates = self.sorted()
            
            var currentStart: Date = sortedDates[0]
            var currentEnd: Date = sortedDates[0]
            var i: Int = 1
            
            while i < sortedDates.count {
                let date = sortedDates[i]

                if date.isSameDay(than: currentEnd.addingOneDay()) {
                    // current date is one day after end date: it is part of the same range
                    currentEnd = date
                    
                } else {
                    // current date is not one day after end date: new range
                    res.append(currentStart...currentEnd)
                    
                    currentStart = sortedDates[i]
                    currentEnd = sortedDates[i]
                }
                
                i += 1
            }
            
            // append last range
            res.append(currentStart...currentEnd)
        }
        
        return res
    }
}
