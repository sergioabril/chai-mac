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
        bodyRequest.uniqueIdentifier = "none" //getUserData().uniqueIdentifier
        bodyRequest.appVersionNumber = version
        bodyRequest.appBuildNumber = build
        bodyRequest.email = email
        bodyRequest.ts = "\(self.getCurrentTimesTamp())"
        //let control = RestControlGenerator.getControlForRestAlertRetrieveRequest(withBody: bodyRequest, version: 1)
        //bodyRequest.control = control;
        
        //Call
        serverRestGeneric(body: bodyRequest, bodyType: RestSendEmailCodesRequest.self,  path: "/v1/au/sendcodes", responseType:  RestSendEmailCodesResponse.self) { (errorMessage, parsedResponse) in
            
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
    
    ///3. Retrieve Alerst (could be consolidated eventually)
    func serverRestAIRetrieve(forPrompt prompt: String,  callback: @escaping (_ success : Bool, _ promptResponse: String?, _ images: [NSImage]?)->())
    {
        DebugHelper.log("Sending AI Request to server for prompt=\(prompt)...")
    
        
        // Some vars
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        // Build the actual request
        let bodyRequest = RestAIRetrieveRequest()
        bodyRequest.uniqueIdentifier = getUniqueIdentifier()
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
            }else if parsedResponse != nil {
                //DebugHelper.log("REST AI RESPONSE= \(parsedResponse!.response)")
                
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
                
                //Set notification if any (or nil)
                self.currentState.notificationUpdateAvailable = parsedResponse!.notificationUpdate
                
                //Send callback
                callback(true, parsedResponse!.response, b64images)
                return
            }
            
            //Callback
            callback(false, nil, nil)
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
