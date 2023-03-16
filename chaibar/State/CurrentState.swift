//
//  CurrentState.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 14/3/23.
//

import Foundation

class CurrentState : ObservableObject {
    /// LIVE
    @Published var promptText : String = ""
    
    /// CACHE
    var chatGPTHistory = [ChatGPTMessage]()
}
