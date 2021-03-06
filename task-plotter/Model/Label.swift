//
//  Label.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation
import SwiftUI

typealias LabelID = UUID

/// A label with a name and a color, that belongs to a project and can be added to a task.
struct Label: Identifiable, Hashable, Equatable, Codable {
    
    let id: LabelID
    
    var name: String
    var color: String
    
    init(id: LabelID = UUID(),
         name: String, color: String) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    /// Generation of available colors for a label.
    static let huesCount = 15
    static let huesShift = 0.05
    static let brightnessShift = 0.1
    static let brightnessOrSaturationCount = 3
    static let brightnessAndSaturationCount = Self.brightnessOrSaturationCount * 2 - 1
    /// Available colors for a label.
    static let availableColors: [String] =
        (0..<Self.brightnessAndSaturationCount).flatMap { (bas: Int) -> [String] in
            let b = bas < Self.brightnessOrSaturationCount ? Self.brightnessOrSaturationCount : Self.brightnessAndSaturationCount - bas
            let s = bas >= Self.brightnessOrSaturationCount ? Self.brightnessOrSaturationCount : bas + 1
            
            let brightness = (Double(b) / Double(Self.brightnessOrSaturationCount)) - Self.brightnessShift
            let saturation = Double(s) / Double(Self.brightnessOrSaturationCount)
            
            let grayBrightness = 1 - (Double(bas) / Double(Self.brightnessAndSaturationCount - 1))
            
            return (0..<Self.huesCount).map { (h: Int) -> String in
                let hue = (Self.huesShift + Double(h) / Double(Self.huesCount)).truncatingRemainder(dividingBy: 1)
                return Color(hue: hue, saturation: saturation, brightness: brightness).ҩhex
            } + [Color(hue: 0, saturation: 0, brightness: grayBrightness).ҩhex] // gray
        }
    
    /// Foreground color (either black or white) that should be shown over the given background color.
    static func foregroundOn(background: String) -> Color {
        let nsColor = NSColor(Color(hex: background))
        let brightness = ((255 * nsColor.redComponent * 299) + (255 * nsColor.greenComponent * 587) + (255 * nsColor.blueComponent * 114)) / 1000
        return brightness > 190 ? .black : .white
    }
    
    /// New label, with a name of the form "New label [n]" (such that it is not already taken) and a new color.
    static func nextAvailableLabel(labels: IndexedArray<Label, LabelID>) -> Label {
        // name
        let availableName: String
        
        if labels.isEmpty {
            availableName = "New label 1"
        } else {
            availableName = (1...labels.count)
                .map { "New label \($0)" }
                .first { labelName in
                    !labels.contains { $0.name == labelName }
                }!
        }
        
        let availableColor = Self.availableColors
            .first { color in
                !labels.contains { $0.color == color }
            } ?? availableColors[0]
        
        return Label(name: availableName, color: availableColor)
    }
}
