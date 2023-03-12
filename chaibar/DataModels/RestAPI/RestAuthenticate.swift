//
//  RestAuthenticate.swift
//  radares
//
//  Created by Sergio Abril Herrero on 5/8/22.
//

import Foundation

/// Request body to send rating
class RestAuthenticateRequest : Encodable{
    //Identification (user UUID)
    var uniqueIdentifier: String?
    //var serverToken: String? //We dont have yet the servertoken mi arma !CurrentState.serverToken
    
    //App build
    var appBuildNumber: String?
    
    //Platform
    var appPlatform: String?
    
    //Language
    var language: String?   //not signed by control
    
    //Locale
    var region: String?   //not signed by control
    
    //Timestamp - REALLY IMPORTANT
    var ts: String?
    
    //Control
    var control: RestControl?
}

/// Response when you send a rating
class RestAuthenticateResponse : Decodable{
    var message: String?                                        //If not empty, maybe something happened
    
    var token: String?                                          //We dont use it but maybe in the future
    
    var requiresAppUpdate: Bool?                                
}
