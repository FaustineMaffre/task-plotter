//
//  IndexedArray.swift
//  task-plotter
//
//  Created by Faustine Maffre on 19/12/2020.
//

import Foundation

/// Collection with ordered elements, whose can also be accessed by an ID. 
struct IndexedArray<Element: Equatable, ID: Hashable>: MutableCollection, RandomAccessCollection, Equatable {
    
    /// Elements of the array.
    var elements: [Element] {
        didSet {
            self.regenerateElementsIndexesByID(from: self.elements, id: self.idPath)
        }
    }
    
    /// Path to the element's ID.
    var idPath: KeyPath<Element, ID>
    
    /// Index of each element of the array, identified by its ID.
    ///
    /// Not modified directly, but re-generated each time element is modified.
    private (set) var elementsIndicesByID: Dictionary<ID, Int>
    
    var ҩcount: Int {
        self.elements.count
    }
    
    var ҩindices: Range<Int> {
        self.elements.indices
    }
    
    var startIndex: Int { 0 }
    var endIndex: Int { self.ҩcount }
    func index(after i: Int) -> Int { i + 1 }
    
    init(elements: [Element] = [], id idPath: KeyPath<Element, ID>) {
        self.elements = elements
        self.idPath = idPath
        
        self.elementsIndicesByID = [:]
        self.regenerateElementsIndexesByID(from: self.elements, id: self.idPath)
    }
    
    /// Re-generates the elements with their indexed by ID dictionary from the array of elements and the element's ID.
    private mutating func regenerateElementsIndexesByID(from elements: [Element], id idPath: KeyPath<Element, ID>) {
        self.elementsIndicesByID =
            Dictionary(uniqueKeysWithValues: elements.enumerated().map { index, element in
                (element[keyPath: idPath], index)
            })
    }
    
    subscript(index: Int) -> Element {
        get {
            self.elements[index]
        }
        set {
            self.elements[index] = newValue
        }
    }
    
    func indexOf(id: ID) -> Int? {
        self.elementsIndicesByID[id]
    }
    
    func indexOf(_ element: Element) -> Int? {
        self.indexOf(id: element[keyPath: self.idPath])
    }
    
    func find(by id: ID) -> Element? {
        if let index = self.indexOf(id: id) {
            return self.elements[index]
        } else {
            return nil
        }
    }
    
    /// True iff the element with the first ID is before the element with the second ID in the elements array; nil if
    /// either one or both of the elements cannot be found in the array.
    func areInIncreasingOrderInArray(first: ID, second: ID) -> Bool? {
        if let indexOfFirst = self.indexOf(id: first), let indexOfSecond = self.indexOf(id: second) {
            return indexOfFirst < indexOfSecond
        } else {
            return nil
        }
    }
    
    /// True iff the first element is before the second in the elements array; nil if either one or both of the elements
    /// cannot be found in the array.
    func areInIncreasingOrderInArray(first: Element, second: Element) -> Bool? {
        if let indexOfFirst = self.indexOf(first), let indexOfSecond = self.indexOf(second) {
            return indexOfFirst < indexOfSecond
        } else {
            return nil
        }
    }
    
    mutating func append(_ newElement: Element) {
        self.elements.append(newElement)
    }
    
    mutating func insert(_ newElement: Element, at index: Int) {
        self.elements.insert(newElement, at: index)
    }
    
    @discardableResult
    mutating func remove(at index: Int) -> Element? {
        self.elements.remove(at: index)
    }
    
    @discardableResult
    mutating func remove(by id: ID) -> Element? {
        if let elementIndex = self.indexOf(id: id) {
            return self.remove(at: elementIndex)
        } else {
            return nil
        }
    }
    
    @discardableResult
    mutating func remove(_ element: Element) -> Element? {
        if let elementIndex = self.indexOf(element) {
            return self.remove(at: elementIndex)
        } else {
            return nil
        }
    }
    
    mutating func move(fromOffsets: IndexSet, toOffset: Int) {
        self.elements.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    static func == (lhs: IndexedArray<Element, ID>, rhs: IndexedArray<Element, ID>) -> Bool {
        lhs.elements == rhs.elements && lhs.idPath == rhs.idPath
    }
}
