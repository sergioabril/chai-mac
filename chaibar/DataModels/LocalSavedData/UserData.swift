//
//  UserData.swift
//  nuit
//
//  Created by Sergio Abril Herrero on 31/1/23.
//

import Foundation

//
// Used to store user details and basic info
//

class UserData : Codable {
    //Misc
    var creationDate: Date?
    var creationRegionCode: String?
    
    //Some stats
    var timesOpened: Int?
    
    //License identity cache
    var licenseEmail: String?
    var serverToken: String?
    var serverTokenExpiration: Date?
}
