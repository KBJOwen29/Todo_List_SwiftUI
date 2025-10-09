//
//  SwiftData_BognalbalApp.swift
//  SwiftData_Bognalbal
//
//  Created by STUDENT on 10/9/25.
//

import SwiftUI
import SwiftData

@main
struct SwiftData_BognalbalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TodoAppView()
        }
        .modelContainer(sharedModelContainer)
    }
}
