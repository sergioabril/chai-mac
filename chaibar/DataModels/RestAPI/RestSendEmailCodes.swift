//
//  RestSendEmailCodes.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 19/3/23.
//

import Foundation

/// Request body to send an alert
class RestSendEmailCodesRequest : Encodable{
    //Identification (user UUID)
    var deviceUniqueIdentifier: String?
    
    //App build
    var appVersionNumber: String?
    var appBuildNumber: String?
    
    //Language & Locale
    var language: String?   //not signed by control
    var region: String?   //not signed by control

    //Request AI specifics
    var email: String?
    
    //Tags
    var tags: [String]?
    
    //Timestamp - REALLY IMPORTANT
    var ts: String?
    
    //Control
    var control: RestControl?
}

/// Response when you request if there is an update
class RestSendEmailCodesResponse : Decodable{
    var message: String?                                        //If not empty, maybe something happened

    var sent: Bool?
}
