//
//  RestNotificationUpdate.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 19/3/23.
// Notification to show update. Usually given back from some REST request

import Foundation
class RestNotificationUpdate : Encodable, Decodable{
    //text
    var text: String?
    //url
    var url: String?
    //Version
    var versionNumner: String?
    var versionBundle: String?
}
