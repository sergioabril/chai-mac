//
//  HotKeyHelper.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 11/3/23.
//  https://stackoverflow.com/questions/28281653/how-to-listen-to-global-hotkeys-with-swift-in-a-macos-app
//
//  Interesting reading if you want to go deeper https://alinpanaitiu.com/blog/apps-outside-app-store/

import Carbon
import AppKit

extension String {
  /// This converts string to UInt as a fourCharCode
  public var fourCharCodeValue: Int {
    var result: Int = 0
    if let data = self.data(using: String.Encoding.macOSRoman) {
      data.withUnsafeBytes({ (rawBytes) in
        let bytes = rawBytes.bindMemory(to: UInt8.self)
        for i in 0 ..< data.count {
          result = result << 8 + Int(bytes[i])
        }
      })
    }
    return result
  }
}

class HotkeySolution {
  static func getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags) -> UInt32 {
    let flags = cocoaFlags.rawValue
    var newFlags: Int = 0

    if ((flags & NSEvent.ModifierFlags.control.rawValue) > 0) {
      newFlags |= controlKey
    }

    if ((flags & NSEvent.ModifierFlags.command.rawValue) > 0) {
      newFlags |= cmdKey
    }

    if ((flags & NSEvent.ModifierFlags.shift.rawValue) > 0) {
      newFlags |= shiftKey;
    }

    if ((flags & NSEvent.ModifierFlags.option.rawValue) > 0) {
      newFlags |= optionKey
    }

    if ((flags & NSEvent.ModifierFlags.capsLock.rawValue) > 0) {
      newFlags |= alphaLock
    }

    return UInt32(newFlags);
  }
    
    private static var callOnOpenHotkeyTrigger : () -> Void = {}

    static func registerOpenHotkey(_callOnTrigger : @escaping (() -> Void) = {}) {
        
        callOnOpenHotkeyTrigger = _callOnTrigger
        
        var hotKeyRef: EventHotKeyRef?
        let modifierFlags: UInt32 =
          getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags.command)

        let keyCode = kVK_ANSI_L
        var gMyHotKeyID = EventHotKeyID()

        gMyHotKeyID.id = UInt32(keyCode)

        // Not sure what "swat" vs "htk1" do.
        gMyHotKeyID.signature = OSType("swat".fourCharCodeValue)
        // gMyHotKeyID.signature = OSType("htk1".fourCharCodeValue)

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        // Install handler.
        InstallEventHandler(GetApplicationEventTarget(), {
              (nextHanlder, theEvent, userData) -> OSStatus in
              // var hkCom = EventHotKeyID()

              // GetEventParameter(theEvent,
              //                   EventParamName(kEventParamDirectObject),
              //                   EventParamType(typeEventHotKeyID),
              //                   nil,
              //                   MemoryLayout<EventHotKeyID>.size,
              //                   nil,
              //                   &hkCom)

            NSLog("Command + L Pressed!")
                
            HotkeySolution.callOnOpenHotkeyTrigger()
                
            return noErr
            /// Check that hkCom in indeed your hotkey ID and handle it.
        }, 1, &eventType, nil, nil)

        // Register hotkey.
        let status = RegisterEventHotKey(UInt32(keyCode),
                                         modifierFlags,
                                         gMyHotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &hotKeyRef)
        assert(status == noErr)
    }
    
    
    // Listen for ESC key
    static func registerEscHotkey(_callOnTrigger : @escaping (() -> Void) = {}) {
        
        //callOnOpenHotkeyTrigger = _callOnTrigger
        
        var hotKeyRef: EventHotKeyRef?
        let modifierFlags: UInt32 = 0

        let keyCode = kVK_Escape
        var gMyHotKeyID = EventHotKeyID()

        gMyHotKeyID.id = UInt32(keyCode)

        // Not sure what "swat" vs "htk1" do.
        gMyHotKeyID.signature = OSType("swat".fourCharCodeValue)
        // gMyHotKeyID.signature = OSType("htk1".fourCharCodeValue)

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        // Install handler.
        InstallEventHandler(GetApplicationEventTarget(), {
              (nextHanlder, theEvent, userData) -> OSStatus in
              // var hkCom = EventHotKeyID()

              // GetEventParameter(theEvent,
              //                   EventParamName(kEventParamDirectObject),
              //                   EventParamType(typeEventHotKeyID),
              //                   nil,
              //                   MemoryLayout<EventHotKeyID>.size,
              //                   nil,
              //                   &hkCom)

            NSLog("ESC Pressed!")
                
            //HotkeySolution.callOnOpenHotkeyTrigger()
                
            return noErr
            /// Check that hkCom in indeed your hotkey ID and handle it.
        }, 1, &eventType, nil, nil)

        // Register hotkey.
        let status = RegisterEventHotKey(UInt32(keyCode),
                                         modifierFlags,
                                         gMyHotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &hotKeyRef)
        assert(status == noErr)
    }
}
