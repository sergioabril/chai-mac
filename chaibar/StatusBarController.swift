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
        
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "staroflife.fill", accessibilityDescription: nil)
            button.action = #selector(statusIconTapped(sender:))
            button.target = self
        }
    }
    
    @objc
    func statusIconTapped(sender: AnyObject)
    {
        Singleton.shared.togglePrompt()
    }
}
