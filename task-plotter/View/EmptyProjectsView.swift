//
//  EmptyProjectsView.swift
//  task-plotter
//
//  Created by Faustine Maffre on 07/12/2020.
//

import SwiftUI

struct EmptyProjectsView: View {
    @ObservedObject var repository: Repository
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                CreateProjectButton(repository: self.repository)
                    .padding()
                
                Spacer()
            }
            Spacer()
        }
    }
}

struct EmptyProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyProjectsView(repository: Repository(labels: [], projects: []))
            .previewLayout(.fixed(width: 800, height: 600))
    }
}
