//
//  RestPurchasesValidateReceipt.swift
//  radares
//
//  Created by Sergio Abril Herrero on 27/7/22.
//

import Foundation

/// Request body to send rating
class RestPurchasesReceiptValidationRequest : Encodable{
    //Identification (user UUID)
    var uniqueIdentifier: String?
    var serverToken: String? //CurrentState.serverToken
    
    //App build
    var appBuildNumber: String?
    
    //Base64 string
    var receipt: String?
    
    //Timestamp - REALLY IMPORTANT
    var ts: String?
    
    //Control
    var control: RestControl?
}

/// Response when you send a rating
class RestPurchasesReceiptValidationResponse : Decodable{
    var message: String?                                        //If not empty, maybe something happened
    
    //var purchases: [UserData.Purchase]?
    
    var consummedIntroductoryPrices : [String]?                 //Array of consummed productIds, which menas they CAN NOT use the introductory price on these ones
    
    var ts: Double?                                             //Server validation timestamp
}
