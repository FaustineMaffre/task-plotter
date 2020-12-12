//
//  Label.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import Foundation
import SwiftUI

typealias LabelID = UUID

struct Label: Identifiable, Hashable, Equatable {
    
    let id: LabelID
    
    var name: String
    var color: String
    
    init(id: LabelID = UUID(),
         name: String, color: String) {
        self.id = id
        self.name = name
        self.color = color
    }
    
    static let huesCount = 16
    static let brightnessOrSaturationCount = 3
    static let brightnessAndSaturationCount = Self.brightnessOrSaturationCount * 2 - 1
    static let availableColors: [String] =
        (0..<Self.brightnessAndSaturationCount).flatMap { (bas: Int) -> [String] in
            let b = bas < Self.brightnessOrSaturationCount ? Self.brightnessOrSaturationCount : Self.brightnessAndSaturationCount - bas
            let s = bas >= Self.brightnessOrSaturationCount ? Self.brightnessOrSaturationCount : bas + 1
            
            let brightness = Double(b) / Double(Self.brightnessOrSaturationCount)
            let saturation = Double(s) / Double(Self.brightnessOrSaturationCount)
            
            return (0..<Self.huesCount).map { (h: Int) -> String in
                let hue = Double(h) / Double(Self.huesCount)
                return Color(hue: hue, saturation: saturation, brightness: brightness).ҩhex
            }
        }
    
    static func foregroundOn(background: String) -> Color {
        let nsColor = NSColor(Color(hex: background))
        let brightness = ((255 * nsColor.redComponent * 299) + (255 * nsColor.greenComponent * 587) + (255 * nsColor.blueComponent * 114)) / 1000
        return brightness > 190 ? .black : .white
    }
    
    static func nextAvailableLabel(labels: [Label]) -> Label {
        // name
        let availableName = (1...labels.count)
            .map { "New label \($0)" }
            .first { labelName in
                !labels.contains { $0.name == labelName }
            }!
        
        let availableColor = Self.availableColors
            .first { color in
                !labels.contains { $0.color == color }
            } ?? availableColors[0]
        
        return Label(name: availableName, color: availableColor)
    }
    
    static func findLabel(id: LabelID, among labels: [Label]) -> Label? {
        labels.first { $0.id == id }
    }
}
