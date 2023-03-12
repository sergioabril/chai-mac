//
//  DigestExtension.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 11/3/23.
//
import Foundation
import CryptoKit

// CryptoKit.Digest utils
extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
