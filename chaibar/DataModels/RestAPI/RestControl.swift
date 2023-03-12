//
//  Control.swift
//  radares
//
//  Created by Sergio Abril Herrero on 23/7/22.
//

import Foundation
import CryptoKit

/// Control Class
public class RestControl : Codable{
    var version: Int?
    var signature: String?
}


// Class to generate controls
public class RestControlGenerator {
    
    //Little value that helps offuscate, added at the end before hashing
    private static var nosfer = "obsessionbeatstalenteverytime"
    
    //* Generic, generator
    static private func eNNNcodddeCooontrolSiiign(bodyString: String) -> String
    {
        //print("Control - encoding bodystring: \(bodyString)")
        
        //DO SOME WORK
        var signature = ""
        
        //HASH IT
        guard let data = bodyString.data(using: .utf8) else { return "" }
        let digest = Insecure.SHA1.hash(data: data)
        //print(digest.data) // 20 bytes
        //print(digest.hexStr) // 2AAE6C35C94FCFB415DBE95F408B9CE91EE846ED
        
        //Save
        signature = digest.hexStr
        
        //print("Control - Signature: \(signature)")
        
        //Return it
        return signature
    }
    /*
    /// 1. Check if any update
    static func getControlForRestDatabaseUpdateCheckRequest(withBody body: RestDatabaseUpdateCheckRequest, version: Int) -> RestControl
    {
        //Current ts
        let timeStampString = body.ts!
        
        //Build body string
        let bodyString = "\(body.uniqueIdentifier!);\(body.appBuildNumber!);\(body.dbCountry!);\(body.dbCurrentVersion!);\(timeStampString);\(RestControlGenerator.nosfer)"
        
        //Create control
        let controlElement = RestControl()
        controlElement.version = version
        controlElement.signature = eNNNcodddeCooontrolSiiign(bodyString: bodyString)
        return controlElement;
    }
     */
}
