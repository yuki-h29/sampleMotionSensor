//
//  sampleMotionSensorApp.swift
//  sampleMotionSensor
//
//  Created by 平野裕貴 on 2023/08/01.
//

import SwiftUI

@main
struct sampleMotionSensorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
