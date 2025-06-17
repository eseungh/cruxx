//
//  ContentView.swift
//  cruxx
//
//  Created by Lee Seung Ho on 6/17/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showRecordingView = false

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
                VStack {
                    Spacer()
                    Button("Start Recording") {
                        showRecordingView = true
                    }
                    .font(.title2)
                    .padding()
                    Spacer()
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                SessionListView()
                    .tabItem {
                        Label("Sessions", systemImage: "list.bullet")
                    }

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .fullScreenCover(isPresented: $showRecordingView) {
                RecordingView()
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
