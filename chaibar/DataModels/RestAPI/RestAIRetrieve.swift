//
//  RestAlertRetrieve.swift
//  radares
//
//  Created by Sergio Abril Herrero on 25/7/22.
//

import Foundation
import CoreLocation

/// Request body to send an alert
class RestAIRetrieveRequest : Encodable{
    //Identification (user UUID)
    var uniqueIdentifier: String?
    var serverToken: String? //CurrentState.serverToken
    
    //App build
    var appBuildNumber: String?

    //Request AI specifics
    var prompt: String?
    var chatHistory: [String]? // 4 sized array of [latMin, latMax, longMin, longMax] that we want to retrieve alerts for
    
    //Tags
    var tags: [String]?
    
    //Timestamp - REALLY IMPORTANT
    var ts: String?
    
    //Control
    var control: RestControl?
}

/// Response when you request if there is an update
class RestAIRetrieveResponse : Decodable{
    var message: String?                                        //If not empty, maybe something happened

    var prompt: String?                                         //Original prompt
    var response: String?                                       //AI Response
    
    var images: [String]?                                       //AI Images response, an array of JSON b64 images
}
