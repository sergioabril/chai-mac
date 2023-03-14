//
//  FloatingBar.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 1/3/23.
//

import Foundation
import AppKit
import Carbon.HIToolbox //to detect escape

// MARK: - Floating Panel

class FloatingBar: NSPanel {
    
    init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {

        // Adding .titled as style masks,
        super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel, .fullSizeContentView], backing: backing, defer: flag)

        // Set this if you want the panel to remember its size/position
        //        self.setFrameAutosaveName("a unique name")

        // Allow the pannel to be on top of almost all other windows
        self.isFloatingPanel = true
        self.level = .floating

        // Allow the pannel to appear in a fullscreen space
        self.collectionBehavior.insert(.fullScreenAuxiliary)

        // While we may set a title for the window, don't show it
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true

        // Since there is no titlebar make the window moveable by click-dragging on the background
        self.isMovableByWindowBackground = true

        // Keep the panel around after closing since I expect the user to open/close it often
        self.isReleasedWhenClosed = false

        // Background alpha
        self.backgroundColor = .clear
        self.hasShadow = true;

        // Activate this if you want the window to hide once it is no longer focused
        //        self.hidesOnDeactivate = true

        // Hide the traffic icons (standard close, minimize, maximize buttons)
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        
    }

    // `canBecomeKey` and `canBecomeMain` are required so that text inputs inside the panel can receive focus
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }
    
    // Important to listen for ESC keys
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        switch Int(event.keyCode) {
        case kVK_Escape:
            //print("Esc pressed")
            //Clear text or hide
            if Singleton.shared.currentState.promptText.isEmpty {
                // Close window
                Singleton.shared.togglePrompt(closeIfOpen: true)
            }else{
                // Clear
                Singleton.shared.currentState.promptText = ""
            }
            //Abort by returning true
            return true
        default:
            //Deferr event to next handler (textfield)
            return super.performKeyEquivalent(with: event)
        }
    }
}


