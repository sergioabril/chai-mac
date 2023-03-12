//
//  RestUserPushRegister.swift
//  radares
//
//  Created by Sergio Abril Herrero on 6/9/22.
//

import Foundation

/// Request body to send rating
class RestUserPushRegisterRequest : Encodable{
    //Identification (user UUID)
    var uniqueIdentifier: String?
    //var serverToken: String? //We MIGHT NOT have yet the servertoken, so we just dont use it for this
   
    //PushToken
    var pushToken: String?
    
    //Timestamp - REALLY IMPORTANT
    var ts: String?
    
    //Control
    var control: RestControl?
}

/// Response when you send a rating
class RestUserPushRegisterResponse : Decodable{
    var message: String?                                        //If not empty, maybe something happened
    
    var success: Bool?                                          //If false, retry in 30secs
}
