//
//  RestValidateEmailCodes.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 23/3/23.
//

import Foundation

/// Request body to send an alert
class RestValidateEmailCodesRequest : Encodable{
    //Identification (user UUID)
    var deviceUniqueIdentifier: String?
    
    //App build
    var appVersionNumber: String?
    var appBuildNumber: String?
    
    //Language & Locale
    var language: String?   //not signed by control
    var region: String?   //not signed by control

    //Request auth
    var email: String?
    var code: String?
    
    //Timestamp - REALLY IMPORTANT
    var ts: String?
    
    //Control
    var control: RestControl?
}

/// Response when you request if there is an update
class RestValidateEmailCodesResponse : Decodable{
    var message: String?                                        //If not empty, maybe something happened

    var serverToken: String?                                      //If not empty, we got a token to call the server!
    
    var serverTokenExpiresInSeconds: Int?                       //Seconds from now
}
