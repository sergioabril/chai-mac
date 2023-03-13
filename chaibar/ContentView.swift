//
//  ContentView.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 1/3/23.
//

import SwiftUI

struct ContentView: View {
    
    
    @State var searchText = ""
    @FocusState private var searchBarIsFocused : Bool
    
    @State var promptResponse : String?
    @State var promptResponseImages: [NSImage]?// = [NSImage(named: "dummyImage")!]
    
    @State private var scrollViewContentSize: CGSize = .zero
    
    @State var isBusy: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
                    
            //SEARCHABLE PACK
            ZStack{
                
                //LEFT ICON
                HStack{
                    Spacer()
                        .frame(width: 15)
                    ZStack{
                        Image(systemName: "staroflife.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(.white)
                    }
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(isBusy ? 360 : 0), anchor: .center)
                    .animation(isBusy
                               ? .linear(duration: 4).repeatForever(autoreverses: true)
                               : .linear,
                               value: isBusy)
                    Spacer()
                }
               
                //SEARCH BAR
                TextField("", text: $searchText)
                    .placeholder(when: searchText.isEmpty) {
                        /// Custom placeholder modifier instead of txfield default
                        /// So we can customize it
                        Text("Type anything...")
                            .foregroundColor(.gray)
                            .padding(.leading, 50)
                            .font(Font.system(size: 25, design: .rounded))
                    }
                    .focused($searchBarIsFocused)
                    .onSubmit {
                        print("On Submbmit \(searchText)")
                        
                        isBusy = true
                        
                        Singleton.shared.serverRestAIRetrieve(forPrompt: searchText) { success, promptResponse, images  in
                            
                            DebugHelper.log("Response AI: Success=\(success) - response=\(promptResponse) imgs=\(images?.count)")
                            DebugHelper.log("Response AI: Response=\(promptResponse)")
                            
                            //Clean images
                            promptResponseImages = nil
                            
                            //Parse and add prompt response
                            if let promptResponse = promptResponse {
                                DebugHelper.log("Response AI: \(promptResponse)")
                                //Stop animation
                                isBusy = false
                                //Clean prompt
                                var cleanPrompt = promptResponse
                                if let range = cleanPrompt.range(of:"\n\n") {
                                    cleanPrompt = cleanPrompt.replacingCharacters(in: range, with:"")
                                }
    
                                //Set prompt
                                withAnimation{
                                    self.promptResponse = cleanPrompt
                                }
                            }else if images != nil {
                                //Nothing, images will show
                                isBusy = false
                                withAnimation{
                                    self.promptResponseImages = images
                                }
                            }else{
                                isBusy = false
                                withAnimation{
                                    self.promptResponse = "error - tODO: show error icon and view"
                                }
                            }
                        }
                      
                    }
                    .disableAutocorrection(true)
                    .textFieldStyle(MyTextFieldStyle())
                    .font(Font.system(size: 28, design: .rounded))
                    .onChange(of: self.searchText) { newValue in
                        if newValue.isEmpty {
                            promptResponse = nil
                            promptResponseImages = nil
                        }
                    }

            }
            .frame(width: 680)
            .padding(0)
            .padding(.vertical, 6)
            //.background(Color.black)
            .background(VisualEffectView(material: NSVisualEffectView.Material.popover, blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
            
            
            //EXPANDIBLE RESPONSE 
            HStack{
                //Hack for scroll to fit content: https://developer.apple.com/forums/thread/671690
                ScrollView(.vertical, showsIndicators: scrollViewContentSize.height > 500 ? true : false) {
                    if promptResponseImages != nil && !promptResponseImages!.isEmpty
                    {
                        /*
                        AsyncImage(url: URL(string: promptResponse!.replacingOccurrences(of: "[IMG=", with: "").replacingOccurrences(of: "]", with: "")))
                        { image in image.resizable() } placeholder: { Color.gray } .frame(width: 340, height: 340) .clipShape(RoundedRectangle(cornerRadius: 25))
                         */
                        
                        
                        Spacer()
                            .frame(height: 20)
                        Image(nsImage: promptResponseImages![0])
                            .resizable()
                            .frame(width: 380, height: 380)
                            //.padding(.vertical, 30) //to compensate the negative spacing of the parent VSTACK
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            //Animate if shown when you are searching a new thing
                            .opacity(isBusy ? 0.5 : 1)
                            .animation(isBusy
                                       ? .linear(duration: 0.5).repeatForever(autoreverses: true)
                                       : .none, value: isBusy)
                            //Context menu
                            .contextMenu {
                                    Button {
                                        // save my code
                                        
                                        let savePanel = NSSavePanel()

                                        savePanel.title = "Save your image"
                                        savePanel.message = "Choose a place to save this image"
                                        savePanel.prompt = "Save now"
                                        let response = savePanel.runModal()
                                    
                                        
                                        
                                    } label: {
                                        Label("Save Image", systemImage: "square.and.arrow.down")
                                    }
                                }
                            //Resize scroll
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        var size = geo.size
                                        size.height += 40 //spacers top/bottom
                                        scrollViewContentSize = size
                                    }
                                    return Color.clear
                                }
                            )
                        
                        Spacer()
                            .frame(height: 20)
                    }else{
                        Text(promptResponse ?? "")
                            .font(Font.system(size: 15, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 30) //to compensate the negative spacing of the parent VSTACK
                            //Animate if shown when you are searching a new thing
                            .opacity(isBusy ? 0.5 : 1)
                            .animation(isBusy
                                       ? .linear(duration: 0.5).repeatForever(autoreverses: true)
                                       : .none, value: isBusy)

                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        scrollViewContentSize = geo.size
                                    }
                                    return Color.clear
                                }
                            )
                    }
                    
                }
                .frame(
                    maxHeight: scrollViewContentSize.height
                )
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: (promptResponse != nil || promptResponseImages != nil) ? 100 : 0)
            //.background(RoundedCorners(color: .black.opacity(0.5), tl: 0, tr: 0, bl: 20, br: 20))
            .background(VisualEffectView(material: NSVisualEffectView.Material.popover, blendingMode: NSVisualEffectView.BlendingMode.withinWindow))
            .clipShape(RoundedCornersShape(tl: 0, tr: 0, bl: 20, br: 20))
            .padding(.horizontal, 10)
            .zIndex(-1) //below the box
            .opacity((promptResponse != nil || promptResponseImages != nil) ? 1 : 0)

            
            //PUSH ALL UP
            Spacer()
           
        }
        .frame(height: 500)
        .padding(0)
    }
}

// MARK: TextField Search Style
struct MyTextFieldStyle: TextFieldStyle {
    /// Custom stuff: https://stackoverflow.com/questions/73051258/swiftui-custom-textfield-with-focus-ring-on-macos
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .textFieldStyle(.plain) //Important, so we dont get background not rounded focus blueish tint
        .padding(10)
        .padding(.leading, 40)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white) //Text color
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.clear)
                //.strokeBorder(Color.red, lineWidth: 1)
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
