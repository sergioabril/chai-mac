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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
      
        
        // The application does not appear in the Dock and does not have a menu
        // bar, but it may be activated programmatically or by clicking on one
        // of its windows.
        NSApp.setActivationPolicy(.accessory)
        
        // Force App Dark mode
        NSApp.appearance = NSAppearance(named: .darkAqua)
        
        // Close main app window
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        // Initial Logic
        _ = Singleton.shared.logicOnStart()
    
        
        // Register Hotkey to open window
        HotkeySolution.registerOpenHotkey(_callOnTrigger: {
            Singleton.shared.togglePrompt()
        })
        
        
        //Start by showing it if not shown after 1 sec
        //If I make it appear before, without delay, it loses focus, so this is the hacky workaround til I find out what's getting focus instead
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Singleton.shared.togglePrompt(closeIfOpen: false)
        }
        

    }

    func applicationWillTerminate(_ aNotification: Notification) {
          // Insert code here to tear down your application
    }
    
}
