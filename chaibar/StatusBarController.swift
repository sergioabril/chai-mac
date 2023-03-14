//
//  StatusBarController.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 1/3/23.
//

import AppKit

class StatusBarController {
    
    private var statusBar : NSStatusBar
    private(set) var statusItem: NSStatusItem
    
    init()
    {
        statusBar = .init()
        
        // Create status bar
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        // Add a menu and a menu item
        let menu = NSMenu()
        
        let showMenuItem = NSMenuItem()
        showMenuItem.title = "Show / Hide Bar"
        showMenuItem.action = #selector(showAppTapped(sender:))
        showMenuItem.target = self
        menu.addItem(showMenuItem)
        
        menu.addItem(.separator())
        
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit"
        quitMenuItem.action = #selector(menuItemQuitTapped(sender:))
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        
        //Set the menu
        self.statusItem.menu = menu
        
        // Add and customize button
        if let button = statusItem.button {
            button.image = NSImage(named: "statusBarIcon")
            button.image?.size = NSSize(width: 16, height: 16) //or it would be to big for the status bar
            //button.action = #selector(showAppTapped(sender:))
            //button.target = self
        }
    }
    
    @objc
    func showAppTapped(sender: AnyObject)
    {
        Singleton.shared.togglePrompt()
    }
        
    @objc
    func menuItemQuitTapped(sender: AnyObject)
    {
        NSApplication.shared.terminate(nil)
    }
}
