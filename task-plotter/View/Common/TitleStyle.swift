//
//  TitleStyle.swift
//  task-plotter
//
//  Created by Faustine Maffre on 08/12/2020.
//

import SwiftUI

extension Text {
    /// Style for a title text in the app.
    func titleStyle() -> Text {
        self
            .font(.title2)
            .bold()
    }
    
    /// Style for a small title text in the app.
    func smallTitleStyle() -> Text {
        self
            .font(.title3)
            .bold()
    }
}
