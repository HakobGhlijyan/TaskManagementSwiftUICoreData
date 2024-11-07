//
//  TaskManagementSwiftUICoreDataApp.swift
//  TaskManagementSwiftUICoreData
//
//  Created by Hakob Ghlijyan on 07.11.2024.
//

import SwiftUI

@main
struct TaskManagementSwiftUICoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
