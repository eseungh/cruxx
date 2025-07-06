//
//  ContentView.swift
//  cruxx
//
//  Created by Lee Seung Ho on 6/17/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showRecordingView = false
    @AppStorage("includeMic") private var includeMic = true
    @AppStorage("countdownSeconds") private var countdownSeconds = 3
    @AppStorage("autoAnalyze") private var autoAnalyze = true

    init() {
        UITabBar.appearance().backgroundColor = .clear
    }

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(edges: .all)

            TabView {
                HomeView(showRecordingView: $showRecordingView)
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
                RecordingView(
                    includeMic: includeMic,
                    countdownSeconds: countdownSeconds,
                    autoAnalyze: autoAnalyze
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
