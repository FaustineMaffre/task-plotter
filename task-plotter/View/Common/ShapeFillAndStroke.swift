//
//  BorderedShape.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

extension Shape {
    func fillAndStroke<Fill: ShapeStyle, Stroke: ShapeStyle>(fill: Fill, stroke: Stroke, strokeWidth: CGFloat = 1) -> some View {
        ZStack {
            self.fill(fill)
            self.stroke(stroke, lineWidth: strokeWidth)
        }
    }
}
