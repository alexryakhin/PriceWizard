//
//  PriceWizardApp.swift
//  PriceWizard
//
//  Created by Alexander Riakhin on 16/02/2026.
//

import SwiftUI

@main
struct PriceWizardApp: App {
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            SidebarCommands()
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button {
                    openWindow(id: AboutView.windowId)
                } label: {
                    Text("About Price Wizard")
                }
            }
        }

        Window("About Price Wizard", id: AboutView.windowId) {
            AboutView()
        }
        .defaultSize(width: 400, height: 400)
    }
}
