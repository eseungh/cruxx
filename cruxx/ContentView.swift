//
//  ContentView.swift
//  cruxx
//
//  Created by Lee Seung Ho on 6/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            TabView {
                Text("녹화 화면 준비 중입니다.")
                    .tabItem {
                        Label("Record", systemImage: "camera")
                    }

                Text("세션 리스트 준비 중입니다.")
                    .tabItem {
                        Label("Sessions", systemImage: "list.bullet")
                    }

                Text("설정 화면 준비 중입니다.")
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding()
            .opacity(0.9)
        }
    }
}

#Preview {
    ContentView()
}
