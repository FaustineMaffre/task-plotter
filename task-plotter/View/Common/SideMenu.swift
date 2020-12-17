//
//  SideMenu.swift
//  task-plotter
//
//  Created by Faustine Maffre on 16/12/2020.
//

import SwiftUI

enum SideMenuSide { case leading, trailing }

struct SideMenu<MainContent: View, SideContent: View>: View {
    let side: SideMenuSide
    
    @Binding var isPresented: Bool
    
    let mainContent: MainContent
    let sideContent: SideContent
    
    init(side: SideMenuSide,
         isPresented: Binding<Bool>,
         @ViewBuilder mainContent: () -> MainContent,
         @ViewBuilder sideContent: () -> SideContent) {
        self.side = side
        self._isPresented = isPresented
        self.mainContent = mainContent()
        self.sideContent = sideContent()
    }
    
    var body: some View {
        if self.side == .leading {
            self.leadingSideView
        } else if self.side == .trailing {
            self.trailingSideView
        }
    }
    
    var leadingSideView: some View {
        HStack(spacing: 0) {
            if self.isPresented {
                HStack(spacing: 0) {
                    self.sideView
                    
                    Divider()
                        .background(Color(NSColor.separatorColor))
                }
                .transition(.move(edge: .leading))
            }
            
            self.mainContent
        }
    }
    
    var trailingSideView: some View {
        HStack(spacing: 0) {
            self.mainContent
            
            if self.isPresented {
                HStack(spacing: 0) {
                    Divider()
                        .background(Color(NSColor.separatorColor))
                    
                    self.sideView
                }
                .transition(.move(edge: .trailing))
            }
        }
    }
    
    var sideView: some View {
        VStack {
            HStack {
                self.sideContent
            }
            
            Spacer()
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}
