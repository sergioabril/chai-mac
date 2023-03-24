//
//  Singleton.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 11/3/23.
//

import Foundation
import SwiftUI

/// The Singleton class defines the `shared` field that lets clients access the
/// unique singleton instance.
/// I added the AVSPeechSynthesizerDelegate recently, and it made me add NSObject as well, just in case we find bugs, here it is
class Singleton: NSObject, NSWindowDelegate {
    
    // MARK: Singleton boilerplate
    
    /// The static field that controls the access to the singleton instance.
    ///
    /// This implementation let you extend the Singleton class while keeping
    /// just one instance of each subclass around.
    static var shared: Singleton = {
        let instance = Singleton()
        // ... configure the instance
        // ...
        return instance
    }()
    
    /// The Singleton's initializer should always be private to prevent direct
    /// construction calls with the `new` operator.
    private override init() {}
    
    // MARK: Pointers
    var currentState = CurrentState()

    // MARK: variables
    var promptPanel: FloatingBar?
        
    // MARK: User Data
    ///Some quick info about the user, like the device identifier used to send requests to the server, the creation date, picked interests, etc
    private let ConstantUserDataKey = "localUserData"
    /// Variable to store lcoal data
    private var userData: UserData?
    /// Check if we are a new user
    func getUserData() -> UserData
    {
        //If on memory, return
        if let loadedOnMemory = userData {
            return loadedOnMemory
        }
        
        //If not on memory, try to retrieve from local prefs
        if let data = UserDefaults.standard.data(forKey: ConstantUserDataKey) {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                
                // Decode Note
                let newLoadedData = try decoder.decode(UserData.self, from: data)
                userData = newLoadedData;
                return userData!
            } catch {
                DebugHelper.logError("Unable to Decode UserData (\(error))")
                fatalError("Error loading Local")
            }
        }
        
        //If we get here, we have no user data! create it
        self.createUserData()
        
        //Return
        return userData!
    }
    /// Save local data
    func saveUserData() {
        let currentUserData = getUserData()
        
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            
            // Encode Note
            let data = try encoder.encode(currentUserData)
            
            // Write/Set Data
            UserDefaults.standard.set(data, forKey: ConstantUserDataKey)
        } catch {
            DebugHelper.logError("Unable to Encode UserData (\(error))")
        }
    }
    /// Create new UserData
    private func createUserData()
    {
        //Create class
        userData = UserData()
        
        //Assign unique identifier
        let identifier = getUniqueIdentifier()
        DebugHelper.log("Created new user with identifier: \(identifier)")
        
        //Save creation date, country and lang
        userData!.creationDate = Date()
        userData!.creationRegionCode = Locale.current.regionCode
        DebugHelper.log("Region code is \(userData!.creationRegionCode!) and Date \(userData!.creationDate!)")
        
        //Assign first open
        userData!.timesOpened = 0
        
        //And save it
        self.saveUserData()
    }
    //Delete
    private func deleteUserData()
    {
        UserDefaults.standard.removeObject(forKey: ConstantUserDataKey)
    }
    
    
    // MARK: Main Logic
    /// Finally, any singleton should define some business logic, which can be
    /// executed on its instance.
    /// I used to call this on the instance generation above, but was a mistake, cause caused exception when calling shared from any method called here
    /// So now I call this on AppDelegate, after creating the instance
    func logicOnStart(){
        // ...
        DebugHelper.log("logicOnStart - Initializing Singleton...")
        /// LOAD IAP's
        ///
        /*
        self.purchaser.startWith(sharedSecret: "fake")

        /// Also refresh receipt
        self.purchaser.refreshSubscriptionsStatus {
            DebugHelper.log("logicOnStart - REFRESH SUBS STATUS OK")
        } failure: { error in
            DebugHelper.logError("logicOnStart - REFRESH Error \(error)")
        }
        */
                

        //Force to get the userData by colling it
        let currentUserData = self.getUserData();
    
        //Increase app counter of times opened
        if currentUserData.timesOpened == nil {
            currentUserData.timesOpened = 0
        }
        currentUserData.timesOpened? += 1
        saveUserData()
        
        
        //
        //Load to currentState the proper serverToken and identity
        //
        
        currentState.licenseEmail = currentUserData.licenseEmail
        currentState.serverToken = currentUserData.serverToken
        currentState.serverTokenExpiration = currentUserData.serverTokenExpiration
        
        if currentState.serverTokenExpiration != nil {
            if Date.now > currentState.serverTokenExpiration! {
                //DebugHelper.log("Token has expired!!!!! Clean")
                cleanLicenseInfo()
            }
        }
        
    }
    
    
    func cleanLicenseInfo()
    {
        currentState.licenseEmail = nil
        currentState.serverToken = nil
        currentState.serverTokenExpiration = nil
        
        let currentUserData = self.getUserData();
        currentUserData.licenseEmail = nil
        currentUserData.serverToken = nil
        currentUserData.serverTokenExpiration = nil
        
        saveUserData()
    }
    
    // MARK: Prompt Panel management
    // Call to toggle open/close
    func togglePrompt(closeIfOpen: Bool = true)
    {
        if self.promptPanel == nil {
            /// Create
            self.createFloatingPanel()
        }else{
            /// Close
            /// only if set to true
            if closeIfOpen {
                self.promptPanel!.close()
                self.promptPanel = nil
                
                /// CLEAN PROMPT AND HISTORY just in cases
                currentState.promptText = ""
                currentState.chatGPTHistory = [ChatGPTMessage]()
            
            }
        }
    }
    
    // Internal to create panel
    private func createFloatingPanel() {
        // Create the SwiftUI view that provides the window contents.
        // I've opted to ignore top safe area as well, since we're hiding the traffic icons
        let contentView = ContentView(currentState: currentState)
          .edgesIgnoringSafeArea(.top)

        // Create the window and set the content view.
        promptPanel = FloatingBar(contentRect: NSRect(x: 0, y: 0, width: 512, height: 80), backing: .buffered, defer: false)

        promptPanel!.title = "Chaibar"
        promptPanel!.contentView = NSHostingView(rootView: contentView)


        // Center doesn't place it in the absolute center, see the documentation for more details
        promptPanel!.center()

        // Shows the panel and makes it active
        promptPanel!.orderFront(nil)
        promptPanel!.makeKey()
        
        /// Important so we handle when it loses focus and remove the var
        promptPanel!.delegate = self

        //print("CREATED!")
    }
    
    // Delegate from NSWindowDelegate that is called when promptPanel loses focus
    func windowDidResignKey(_ notification: Notification) {
        if let panel = notification.object as? NSWindow {
            
            //print("lost focus. is floatingPanel=\(panel == self.promptPanel)")
            if self.promptPanel == panel {
                if currentState.isBusyQueryingAI {
                    DebugHelper.log("Dont dismiss cause busy querying AI")
                }else{
                    //self.promptPanel?.close()
                    //self.promptPanel = nil
                }
            }else{
                //panel.close()
            }
            
            //Clean prompt & history
            //currentState.promptText = ""
            //currentState.chatGPTHistory = [ChatGPTMessage]()
        }
    }
    
    // MARK: API Calls
    ///Generic for all. T is the type of the request body, and K the response, so I can parse everything here
    ///If there is an error, the completion handler returns the error as a string second parameter. Otherwise, we return the response object
    func serverRestGeneric<T,K>(body: Encodable, bodyType: T.Type, path: String, responseType: K.Type, completionHandler: @escaping ( _ errorString : String?, _ response: K?) -> Void) where T : Encodable, K : Decodable
    {
        //DebugHelper.log("serverRestGeneric - Starting...")
        
        //Cast so we can encode
        let castedBody = body as! T
        
        //Try to turn into JSON
        var bodyJsonData: Data?
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            
            // Encode Note
            bodyJsonData = try encoder.encode(castedBody)
        } catch {
            DebugHelper.logError("Unable to Encode RestGenericRequest (\(error))")
        }
        if bodyJsonData == nil {
            DebugHelper.logError("Error encoding class into json!")
            return
        }
        //let str = String(decoding: bodyJsonData!, as: UTF8.self)
        //DebugHelper.log("STRING JSON \(str)")
        
        // Create a URLRequest for an API endpoint
        let url = URL(string: "\(RestApi.baseUrl)\(path)")!
        var request = URLRequest(url: url)
        
        // Change the URLRequest to a POST request
        request.httpMethod = "POST"
        request.httpBody = bodyJsonData!
        
        // set header fields (important, or the server will not parse the body content as JSON)
        request.setValue("application/json",
                         forHTTPHeaderField: "Content-Type")
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Create the HTTP request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            //Send to completion handler
            if let httpResponse = response as? HTTPURLResponse {
                //DebugHelper.log(">>> HTTP STATUS CODE: \(httpResponse.statusCode)")
                if httpResponse.statusCode > 200
                {
                    completionHandler(">>> HTTP Error. Status Code: \(httpResponse.statusCode)", nil)
                }
            }
            
            if let error = error {
                // Handle HTTP request error
                // Maybe lack of connection, etc
                completionHandler(error.localizedDescription, nil)
            } else if let data = data {
                // Handle HTTP request response
                //let str = String(decoding: data, as: UTF8.self)
                //DebugHelper.log(">>> HTTP REQUEST RESPONSE (string): \(str)")
                //Try to parse to the proper class
                //If not on memory, try to retrieve from local prefs
                do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()
                    
                    // Decode Data
                    let parsedResponse = try decoder.decode(responseType, from: data)
                    
                    //Return response on the completion handler
                    completionHandler(nil, parsedResponse)
                    
                } catch {
                    completionHandler("Unable to Decode response=\(error)", nil)
                }
                
                
            } else {
                // Handle unexpected error
                completionHandler("Unknown request error", nil)
            }
        }
        task.resume()
    }
    ///1. Request to send Email Login Code
    func serverRestSendEmailCode(forEmail email: String,  callback: @escaping (_ success : Bool, _ message: String?)->())
    {
        DebugHelper.log("Sending request to get email codes at=\(email)...")
        
        
        // Some vars
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        // Build the actual request
        let bodyRequest = RestSendEmailCodesRequest()
        bodyRequest.deviceUniqueIdentifier = getUniqueIdentifier() //getUserData().uniqueIdentifier
        bodyRequest.appVersionNumber = version
        bodyRequest.appBuildNumber = build
        bodyRequest.email = email
        bodyRequest.ts = "\(self.getCurrentTimesTamp())"
        //let control = RestControlGenerator.getControlForRestAlertRetrieveRequest(withBody: bodyRequest, version: 1)
        //bodyRequest.control = control;
        
        //Call
        serverRestGeneric(body: bodyRequest, bodyType: RestSendEmailCodesRequest.self,  path: "/v1/au/sendmailcodes", responseType:  RestSendEmailCodesResponse.self) { (errorMessage, parsedResponse) in
            
            if let error = errorMessage {
                //NETWORK ERROR
                DebugHelper.logError("REST ERROR: \(error)")
            }else if parsedResponse != nil {
                //Send callback
                callback(parsedResponse!.sent ?? false, parsedResponse!.message)
                return
            }
            
            //Callback
            callback(false, "Cant reach server")
        }
    }
    ///2. Request to validate email and code
    func serverRestValidateEmailCodes(forEmail email: String, code: String,  callback: @escaping (_ success: Bool, _ message: String?)->())
    {
        DebugHelper.log("Sending request to validate email=\(email) with code=\(code)...")
        
        
        // Some vars
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        // Build the actual request
        let bodyRequest = RestValidateEmailCodesRequest()
        bodyRequest.deviceUniqueIdentifier = getUniqueIdentifier() //getUserData().uniqueIdentifier
        bodyRequest.appVersionNumber = version
        bodyRequest.appBuildNumber = build
        bodyRequest.email = email
        bodyRequest.code = code;
        bodyRequest.ts = "\(self.getCurrentTimesTamp())"
        //let control = RestControlGenerator.getControlForRestAlertRetrieveRequest(withBody: bodyRequest, version: 1)
        //bodyRequest.control = control;
        
        //Call
        serverRestGeneric(body: bodyRequest, bodyType: RestValidateEmailCodesRequest.self,  path: "/v1/au/validatemailcodes", responseType:  RestValidateEmailCodesResponse.self) { (errorMessage, parsedResponse) in
            
            if let error = errorMessage {
                //NETWORK ERROR
                DebugHelper.logError("ValidateEmailCodes REST ERROR: \(error)")
            }else if parsedResponse != nil {
                
                //If success, save stuff
                if let receivedServerToken = parsedResponse!.serverToken {
                    if !receivedServerToken.isEmpty {
                        DebugHelper.log("Received server token! Success")
                        
                        /// IMPORTANT: SET THIS ON MAIN THREAD OR THEY WONT BE PUBLISHED
                        DispatchQueue.main.async {
                            /// Save server token
                            self.currentState.serverToken = receivedServerToken
                            
                            if let expiresIn = parsedResponse!.serverTokenExpiresInSeconds {
                                let expiryDate = Date(timeIntervalSinceNow: TimeInterval(expiresIn))
                                self.currentState.serverTokenExpiration = expiryDate
                                
                                DebugHelper.log("Server token expires in \(expiresIn)s, so at \(expiryDate)")
                            }else{
                                self.currentState.serverTokenExpiration = nil
                            }

                            /// Save email as identity for user
                            self.currentState.licenseEmail = email
    
                            let currentUserD = self.getUserData()
                            currentUserD.licenseEmail = self.currentState.licenseEmail
                            currentUserD.serverToken = self.currentState.serverToken
                            currentUserD.serverTokenExpiration = self.currentState.serverTokenExpiration
                            self.saveUserData()
                            
                            
                            DebugHelper.log("Server token expires at \(self.currentState.serverTokenExpiration)")
                        }

                        
                        //Success
                        callback(true, nil)
                        return
                    }
                }
                
                //Send callback
                callback(false, parsedResponse!.message ?? "unknown error")
                return
            }
            
            //Callback
            callback(false, "Cant reach server")
        }
    }
    
    ///3. Retrieve Alerst (could be consolidated eventually)
    func serverRestAIRetrieve(forPrompt prompt: String,  callback: @escaping (_ success : Bool, _ errorMessage: String?, _ promptResponse: String?, _ images: [NSImage]?)->())
    {
        DebugHelper.log("Sending AI Request to server for prompt=\(prompt)...")
    
        
        // Some vars
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        // Build the actual request
        let bodyRequest = RestAIRetrieveRequest()
        bodyRequest.deviceUniqueIdentifier = getUniqueIdentifier()
        bodyRequest.serverToken = currentState.serverToken ?? "none"
        bodyRequest.appVersionNumber = version
        bodyRequest.appBuildNumber = build
        bodyRequest.engine = .chatgpt
        bodyRequest.prompt = prompt
        bodyRequest.chatHistory = currentState.chatGPTHistory
        bodyRequest.ts = "\(self.getCurrentTimesTamp())"
        //let control = RestControlGenerator.getControlForRestAlertRetrieveRequest(withBody: bodyRequest, version: 1)
        //bodyRequest.control = control;
        
        
        // Add to history if chat GPT so we ca use later on
        if true {
            var newPromptChatGPT = ChatGPTMessage()
            newPromptChatGPT.role = .user
            newPromptChatGPT.content = prompt
            Singleton.shared.currentState.chatGPTHistory.append(newPromptChatGPT)
        }
        
        //Evaluate tags
        if prompt.contains("/image")
        {
            bodyRequest.tags = ["image"]
        }
        
        //Call
        serverRestGeneric(body: bodyRequest, bodyType: RestAIRetrieveRequest.self,  path: "/v1/ai/request", responseType: RestAIRetrieveResponse.self) { (errorMessage, parsedResponse) in
            
            if let error = errorMessage {
                //NETWORK ERROR
                DebugHelper.logError("REST ERROR: \(error)")
                callback(false, error, nil, nil)
                return
            }else if parsedResponse != nil {
                //DebugHelper.log("REST AI RESPONSE= \(parsedResponse!.response)")
                
                /// If we get a specific server error, show?
                if let specificMessageError = parsedResponse?.message {
                    callback(false, specificMessageError, nil, nil)
                    return
                }
                
                /// Before anything, Save some stuff like for chat history and notification update
                DispatchQueue.main.async {
                    
                    /// Save response into chat as well!
                    // Add to history if chat GPT so we ca use later on
                    if let responsegpt = parsedResponse!.response {
                        var newResponseChatGPT = ChatGPTMessage()
                        newResponseChatGPT.role = .assistant
                        newResponseChatGPT.content = responsegpt
                        Singleton.shared.currentState.chatGPTHistory.append(newResponseChatGPT)
                    }
                    
                    //Set notification if any (or nil)
                    self.currentState.notificationUpdateAvailable = parsedResponse!.notificationUpdate
                }
                
                //Parse and add images
                var b64images: [NSImage]?
                if let givenImagesArray = parsedResponse!.images {
                    for imgb64 in givenImagesArray {
                        if let encodedImage = imgb64 as? String,
                           let imageData = Data(base64Encoded: encodedImage, options: .ignoreUnknownCharacters),
                           let image = NSImage(data: imageData) {
                            print(image.size)
                            if b64images == nil {
                                b64images = [NSImage]()
                            }
                            b64images!.append(image)
                        }
                    }
                }
                
                if b64images != nil && b64images!.isEmpty == false  && b64images!.count > 0{
                    //Special callback removing response so no text is shown (which in case of images, it's their prompt for dall-e)
                    //TODO: maybe handle this con the content view, displaying this text as ALT of the image?
                    //Send callback
                    callback(true, nil, nil, b64images)
                }else{
                    //Regular callback
                    //Send callback
                    callback(true, nil, parsedResponse!.response, b64images)
                }
                
                return
            }
            
            //Callback
            //callback(false, nil, nil, nil)
        }
    }
    
    // MARK: Global Helpers to be used here
    /// Get timestamp since 1970 in seconds
    func getCurrentTimesTamp() -> CLong {
        return CLong(Date.timeIntervalBetween1970AndReferenceDate+Date.timeIntervalSinceReferenceDate)
    }
    /// Get unique identifier, and keep the same even if they uninstall the app, thanks to keychain
    func getUniqueIdentifier() -> String {
        guard let uniqueDeviceId = KeychainHelper.shared.loadUUID() else {
            let identifier = UUID()
            let identifierString = identifier.uuidString;
            KeychainHelper.shared.saveUUID(uuid: identifierString)
            
            DebugHelper.log("getUniqueIdentifier - NEW - \(identifierString)")
            
            return identifierString
        }
        DebugHelper.log("getUniqueIdentifier - OLD - \(uniqueDeviceId)")
        return uniqueDeviceId
    }
    
}
