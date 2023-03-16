//
//  ChatGPTMessage.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 16/3/23.
//

import Foundation

enum ChatGPTRole : String, Codable {
    case assistant
    case user
}

class ChatGPTMessage: Codable {
    //  Examples of responses
    //  {role: "assistant", content:"No message"}
    //  {role: "user", content: prompt}
    var role: ChatGPTRole?
    var content: String?
}
