//
//  CurrentState.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 14/3/23.
//

import Foundation

class CurrentState : ObservableObject {
    /// INTERNAL
    @Published var licenseEmail: String?
    @Published var serverToken: String?
    @Published var serverTokenExpiration: Date?
    
    /// LOCKS
    var isBusyQueryingAI: Bool = false
    
    /// LIVE
    @Published var promptText : String = ""
    @Published var notificationUpdateAvailable: RestNotificationUpdate?
    
    /// CACHE
    var chatGPTHistory = [ChatGPTMessage]()
}
