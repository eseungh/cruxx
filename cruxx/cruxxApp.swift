//
//  cruxxApp.swift
//  cruxx
//
//  Created by Lee Seung Ho on 6/17/25.
//

import SwiftUI

@main
struct cruxxApp: App {
    private let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
