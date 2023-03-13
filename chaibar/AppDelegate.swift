//
//  AppDelegate.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 1/3/23.
//

import Foundation
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    
    var statusBar: StatusBarController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
      
        // The application does not appear in the Dock and does not have a menu
        // bar, but it may be activated programmatically or by clicking on one
        // of its windows.
        NSApp.setActivationPolicy(.accessory)
        
        // Create status bar
        statusBar = StatusBarController()
                
        // Register Hotkey to open window
        HotkeySolution.registerOpenHotkey(_callOnTrigger: {
            Singleton.shared.togglePrompt()
        })
        
        // Register ESC key
        //HotkeySolution.registerEscHotkey(_callOnTrigger: {
            //TODO: clean text OR hide bar if no text
        //})
    }

    func applicationWillTerminate(_ aNotification: Notification) {
          // Insert code here to tear down your application
    }
    
}
