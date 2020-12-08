//
//  ContentView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var repository: Repository
    
    var body: some View {
        VStack(spacing: 0) {
            ProjectMenu(repository: self.repository)
                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
            
            Divider()
                .background(Color(NSColor.separatorColor))
            
            ProjectView(repository: self.repository)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(repository: TestRepositories.repository)
            .previewLayout(.fixed(width: 1200, height: 800))
    }
}
