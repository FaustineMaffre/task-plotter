//
//  HStackWrap.swift
//  task-plotter
//
//  Created by Faustine Maffre on 14/12/2020.
//

import SwiftUI

// Inspired from https://stackoverflow.com/a/62103264 
struct HStackWrap<Element: Hashable, ElementView: View>: View {
    let elements: [Element]
    
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    
    let elementView: (Int, Element) -> ElementView
    
    @State private var totalHeight = CGFloat.zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: self.totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(self.elements.indices, id: \.self) { elementIndex in
                self.elementView(elementIndex, self.elements[elementIndex])
                    .alignmentGuide(.leading) { dimension in
                        if (abs(width - dimension.width) > geometry.size.width) {
                            width = 0
                            height -= dimension.height + self.verticalSpacing
                        }
                        
                        let result = width
                        
                        if elementIndex == self.elements.count - 1 {
                            width = 0 // last item
                        } else {
                            width -= dimension.width + self.horizontalSpacing
                        }
                        
                        return result
                    }
                    .alignmentGuide(.top) { dimension in
                        let result = height
                        
                        if elementIndex == self.elements.count - 1 {
                            height = 0 // last item
                        }
                        
                        return result
                    }
            }
        }.background(self.viewHeightReader())
    }
    
    private func viewHeightReader() -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                self.totalHeight = rect.size.height
            }
            return .clear
        }
    }
}
