//
//  RestNotificationUpdate.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 19/3/23.
//

import Foundation
/// Notification to show update
class RestNotificationUpdate : Encodable, Decodable{
    //text
    var text: String?
    //url
    var url: String?
    //Version
    var versionNumner: String?
    var versionBundle: String?
}
