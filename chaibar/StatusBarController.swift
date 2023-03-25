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
    
    private var showMenuItem: NSMenuItem = NSMenuItem()
    private var accountItem: NSMenuItem = NSMenuItem()
    
    init()
    {
        statusBar = .init()
        
        // Create status bar
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        // Add a menu and a menu item
        let menu = NSMenu()
                
        showMenuItem = NSMenuItem()
        showMenuItem.title = "Toggle bar (⌘+E)"
        showMenuItem.action = #selector(showAppTapped(sender:))
        showMenuItem.target = self
        showMenuItem.isHidden = true
        menu.addItem(showMenuItem)
        
        menu.addItem(.separator())
        
        accountItem = NSMenuItem()
        accountItem.title = "Login"
        accountItem.action = #selector(licenseTapped(sender:))
        accountItem.target = self
        menu.addItem(accountItem)
        //menu.addItem(.separator())
        
        let helpMenuItem = NSMenuItem()
        helpMenuItem.title = "Contact"
        helpMenuItem.action = #selector(helpTapped(sender:))
        helpMenuItem.target = self
        menu.addItem(helpMenuItem)
        
        //menu.addItem(.separator())
        
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit Chai"
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
        
        
        /// Updatre bar options appeareances
        updateBarOptions()
    }
    
    // MARK: Refresh methods
    func updateBarOptions()
    {
        let loggedIn = Singleton.shared.currentState.licenseEmail != nil && !Singleton.shared.currentState.licenseEmail!.isEmpty
        
        if loggedIn {
            showMenuItem.isHidden = false;
            
            accountItem.title = "\(Singleton.shared.currentState.licenseEmail!) (logout)"
        }else{
            showMenuItem.isHidden = true;
            
            accountItem.title = "Login"
        }
    }
    
    // MARK: Methods
    @objc
    func showAppTapped(sender: AnyObject)
    {
        Singleton.shared.togglePrompt()
    }
    
    @objc
    func licenseTapped(sender: AnyObject)
    {
        let loggedIn = Singleton.shared.currentState.licenseEmail != nil && Singleton.shared.currentState.licenseEmail!.isEmpty == false
        if loggedIn {
            /// Logout
            //print("license tapped - clean cause its \(Singleton.shared.currentState.licenseEmail)")
            Singleton.shared.cleanLicenseInfo()
        }else{
            /// Show login prompt
            //print("license tapped - toggle open license")
            Singleton.shared.togglePrompt(closeIfOpen: false)
        }
        updateBarOptions()
    }
    
    @objc
    func helpTapped(sender: AnyObject)
    {
        NSWorkspace.shared.open(URL(string: "mailto:hola@nada.studio")!)
    }
        
    @objc
    func menuItemQuitTapped(sender: AnyObject)
    {
        NSApplication.shared.terminate(nil)
    }
}
