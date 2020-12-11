//
//  CreateDeleteButton.swift
//  task-plotter
//
//  Created by Faustine Maffre on 11/12/2020.
//

import SwiftUI

struct CreateDeleteEditButton: View {
    let image: Image
    let text: String?
    let action: () -> Void
    
    init(image: Image, text: String? = nil, action: @escaping () -> Void) {
        self.image = image
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button(action: self.action) {
            HStack(spacing: 0) {
                self.image
                    .imageScale(.large)
                    .frame(width: 30, height: 30)
                
                if let text = self.text {
                    Text(text)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
