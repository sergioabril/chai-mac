//
//  RestApi.swift
//  radares
//
//  Created by Sergio Abril Herrero on 23/7/22.
//

import Foundation

class RestApi {
    static var baseUrl = DebugHelper.API_DEBUG_MODE ? "http://127.0.0.1:3001" : "https://backend.chaibar.ai"
}
