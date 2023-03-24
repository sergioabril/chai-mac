//
//  DebugHelper.swift
//  radares
//
//  Created by Sergio Abril Herrero on 1/8/22.
//

import Foundation

class DebugHelper {
    /// When true, we use the debug local api mode
    public static let API_DEBUG_MODE = false
    
    /// LOG
    public static let LOG_DEBUG_VERBOSE = true
    
    ///func print
    public static func log(_ items: Any...){
        //Swift.print("[Debug Log]")
        //Swift.print(items)
        
        if LOG_DEBUG_VERBOSE == false {
            return
        }
        
        if items.count == 1 {
            print("[Info] \(items.first ?? "NO_VALUE")")
        }else{
            print("[Info] \(items)")
        }
    }
    public static func logWarning(_ items: Any...){
        //Swift.print("[Debug LogWarning]")
        if items.count == 1 {
            print("[Warning] \(items.first ?? "NO_VALUE")")
        }else{
            print("[Warning] \(items)")
        }
    }
    public static func logError(_ items: Any...){
        //Swift.print("[Debug LogError]")
        if items.count == 1 {
            print("[Err] \(items.first ?? "NO_VALUE")")
        }else{
            print("[Error \(items)")
        }
    }
}
