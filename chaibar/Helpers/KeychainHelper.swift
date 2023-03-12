//
//  KeychainHelper.swift
//  radares
//
//  Created by Sergio Abril Herrero on 23/8/22.
//  https://github.com/dagostini/DAKeychain/blob/master/DAKeychain/Classes/DAKeychain.swift

import Security
import Foundation

/**
 *  User defined keys for new entry
 *  Note: add new keys for new secure item and use them in load and save methods
 */

let keyUuid = "KeyForUUID"


class KeychainHelper {
    
    
    open var loggingEnabled = false
    
    private init() {}
    public static let shared = KeychainHelper()
    
    /// EXTERNAL
    public func saveUUID(uuid: String)
    {
        DispatchQueue.global().sync(flags: .barrier) {
            self.save(uuid, forKey: keyUuid)
        }
    }
    public func loadUUID() -> String?{
        let resultRead = load(withKey: keyUuid)
        if(resultRead == nil){
            /// I started testing it with a different security key, that did not persist between devices
            /// I switched but kept the keyname, so it fails to read becaise the secFormatKey is the old one that did not persist
            /// So in those cases, try to find key for old security key format, and if success, return that (but delete it so never happen agains)
            let resultReadOld = load_OLD(withKey: keyUuid)
            if(resultReadOld != nil)
            {
                /// ** I think this is not going to be triggered successfully by nobody, just sergio's phone **
                logPrint("[OLD] Load Worked!: ", resultReadOld!)
                //Migrate to new by deleting old entry with wrong sec key
                //1. delete old
                delete_OLD(forKey: keyUuid)
                logPrint("[OLD] Is now deleted")
                //2. Order to save, because its not saved if we dont do it here, as it's thought to be an old one, and singleton does not save olds
                //Order to save on new format
                DispatchQueue.global().sync(flags: .barrier) {
                    self.save(resultReadOld, forKey: keyUuid)
                }
                //Return
                return resultReadOld
            }
        }
        return resultRead
    }
    
    /// GENERIC NOT SURE WHO USES IT
    open subscript(key: String) -> String? {
        get {
            return load(withKey: key)
        } set {
            DispatchQueue.global().sync(flags: .barrier) {
                self.save(newValue, forKey: key)
            }
        }
    }
    
    private func save(_ string: String?, forKey key: String) {
        let query = keychainQuery(withKey: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)
        
        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
                logPrint("Update status: ", status)
            } else {
                let status = SecItemDelete(query)
                logPrint("Delete status: ", status)
            }
        } else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                let status = SecItemAdd(query, nil)
                logPrint("Update status: ", status)
            }
        }
    }
    
    private func load(withKey key: String) -> String? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
        else {
            logPrint("Load status: ", status)
            return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }
    
        
    
    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAfterFirstUnlock, forKey: kSecAttrAccessible as String) //available after unlock, and migrates to new devices
        return result
    }
    
    // MARK: Compatibility Old kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    
    //OLD: for sergio if failed the old keyQuery mode
    private func load_OLD(withKey key: String) -> String? {
        let query = keychainQuery_OLD(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
        else {
            logPrint("[OLD] Load status: ", status)
            return nil
        }
        logPrint("[OLD] Worked!")
        return String(data: resultsData, encoding: .utf8)
    }
    
    ///OLD Method I created to delete old entries that where using the key "kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly" (only Sergio
    private func delete_OLD(forKey key: String) {
        logPrint("[OLD] Lets delete old so it can be saved later on")
        let query = keychainQuery_OLD(withKey: key)
        let status = SecItemDelete(query)
        logPrint("[OLD] Delete status: ", status)
    }
    
    ///OLD to retrieve (only for sergio) the old one with "kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly"
    private func keychainQuery_OLD(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, forKey: kSecAttrAccessible as String) //available after unlock, and migrates to new devices
        return result
    }
    
    //MARK: Print
    
    private func logPrint(_ items: Any...) {
        if loggingEnabled {
            print(items)
        }
    }
}
