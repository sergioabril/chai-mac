//
//  CurrentState.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 14/3/23.
//

import Foundation

class CurrentState : ObservableObject {
    /// INTERNAL
    var serverToken: String?
    
    /// LOCKS
    var isBusyQueryingAI: Bool = false
    
    /// LIVE
    @Published var promptText : String = ""
    @Published var notificationUpdateAvailable: RestNotificationUpdate?
    
    /// CACHE
    var chatGPTHistory = [ChatGPTMessage]()
}
