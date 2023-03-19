//
//  chaibarApp.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 1/3/23.
//

import SwiftUI

@main
struct chaibarApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            //LoginView(currentState: Singleton.shared.currentState)
        }
    }
}
