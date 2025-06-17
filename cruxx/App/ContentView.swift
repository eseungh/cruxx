//
//  ContentView.swift
//  cruxx
//
//  Created by Lee Seung Ho on 6/17/25.
//

import SwiftUI

struct ContentView: View {
    init() {
        UITabBar.appearance().backgroundColor = .clear
    }

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            TabView {
                Text("Home")
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                Text("Record")
                    .tabItem {
                        Label("Record", systemImage: "camera")
                    }

                Text("Sessions")
                    .tabItem {
                        Label("Sessions", systemImage: "list.bullet")
                    }

                Text("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .padding(.bottom, 24)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 25)
            )
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
        }
    }
}

#Preview {
    ContentView()
}
