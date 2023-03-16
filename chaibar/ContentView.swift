//
//  ContentView.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 1/3/23.
//

import SwiftUI
import Highlightr

struct ContentView: View {
    
    
    @ObservedObject var currentState: CurrentState
    
    @FocusState private var searchBarIsFocused : Bool
    
    @State var promptResponse : String? //= "Para crear un loop en Swift:\n\n```\nfor i in 1...5 {\n print(i)\n}\n```\nTambién hay otros tipos de bucles en Swift como `i=1` y `1.0`, como el bucle while y el bucle repeat-while. ¿Te gustaría que te explique más sobre ellos?"
    
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
                        Image("barIcon")
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
                TextField("", text: $currentState.promptText)
                    .placeholder(when: currentState.promptText.isEmpty) {
                        /// Custom placeholder modifier instead of txfield default
                        /// So we can customize it
                        Text("Type anything...")
                            .foregroundColor(.gray)
                            .padding(.leading, 55)
                            .font(Font.system(size: 25, design: .rounded))
                    }
                    .focused($searchBarIsFocused)
                    .onSubmit {
                        print("On Submbmit \(currentState.promptText)")
                        
                        isBusy = true
                        
                        Singleton.shared.serverRestAIRetrieve(forPrompt: currentState.promptText) { success, promptResponse, images  in
                            
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
                                    self.promptResponse = "⚠️ Error reaching servers"
                                }
                            }
                        }
                      
                    }
                    .disableAutocorrection(true)
                    .textFieldStyle(MyTextFieldStyle())
                    .font(Font.system(size: 28, design: .rounded))
                    .onChange(of: currentState.promptText) { newValue in
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
                            .overlay(
                                Button(action: {
                                    //Copy text
                                    let pasteboard = NSPasteboard.general
                                    //pasteboard.declareTypes([.string], owner: nil)
                                    pasteboard.clearContents()
                                    pasteboard.writeObjects([promptResponseImages![0]])
                                    //Animate
                                    //pressedCopy = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        // your code here
                                        //pressedCopy = false
                                    }
                                    
                                }, label: {
                                        Image(systemName: "doc.on.doc")
                                    })
                                    .offset(
                                        x: -10, y: 10
                                    )
                                ,
                                alignment: .topTrailing
                            )
                        
                        Spacer()
                            .frame(height: 20)
                    }else{
                        parseResponse(text: promptResponse ?? "")
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
    
    
    /// Method to parse syntaxis for ChatGPT response
    func parseResponse(text: String) -> some View {
        
        /// Separate by code blocks
        var responseComponents = text.components(separatedBy: "```");
        
        return VStack {
            ForEach(Array(responseComponents.enumerated()), id:\.element){ ind, comp in
                if ind > 0 && ind % 2 != 0 {
                    ///It's code
                    CodeBlock(codeTextBlock: "```\(comp)```")
                }else{
                    //Regular with no CODE BLOCK
                    //BUT: check if there is inline text code
                    var inlineCodeComponents = comp.components(separatedBy: "`");
                    if inlineCodeComponents.count > 0 {
                        //Combine texts: regular and possible inline codes
                        //Reduce combines with next fragment
                        //use this to get index: https://stackoverflow.com/questions/28012205/map-or-reduce-with-index-in-swift
                        inlineCodeComponents.enumerated().reduce(Text("")) { (accumulate, current) in
                            //return accumulate + current.0 * current.1
                            //                          ^           ^
                            //                        index      element
                            
                            if current.0 > 0 && current.0 % 2 != 0 {
                                //Parse inline code
                                return accumulate + parseCodeInline(rawText: "`\(current.1)`")
                            }else{
                                //Regular text with no inline code
                                return accumulate + Text(current.1)
                            }
                            
                        }
                        .font(Font.system(size: 15, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading) //applies to the inlineCodeComponents reduced combined Text
                        
                    }else{
                        //PLAIN OLD, JUST TEXT
                        Text(comp)
                            .font(Font.system(size: 15, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                   
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 30)
        .padding(.vertical, 30)
        //Animate if shown when you are searching a new thing
        .opacity(isBusy ? 0.5 : 1)
        .animation(isBusy
                   ? .linear(duration: 0.5).repeatForever(autoreverses: true)
                   : .none, value: isBusy)

    }
    
    /// Method to parse syntaxis for ChatGPT response
    func parseCodeInline(rawText: String) -> Text {
        /// Split and get both language and code
        let splitCodeblock = rawText.components(separatedBy: "`")
        if splitCodeblock.count < 2 {
            //No code to parse
            return Text(rawText)
        }
        
        //Parse
        var code = splitCodeblock[1]
        
        //If empty, also dont return
        if code.isEmpty {
            return Text(rawText)
        }

        /// Prepare highlight
        let highlightr = Highlightr()
        highlightr!.setTheme(to: "paraiso-dark")
        // You can omit the second parameter to use automatic language detection.
        let highlightedCode = highlightr!.highlight(String(code))
        
        // Convert NSAttributedString to Attributed string to use on SwiftUI
        do {
            let a = try AttributedString(highlightedCode!)
            return Text(a)
        }catch{
            DebugHelper.logError("Error parsing inline code. Return regular. ERROR=\(error)")
            return Text(rawText)
        }
        

    }
}

// MARK: TextField Search Style
struct MyTextFieldStyle: TextFieldStyle {
    /// Custom stuff: https://stackoverflow.com/questions/73051258/swiftui-custom-textfield-with-focus-ring-on-macos
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .textFieldStyle(.plain) //Important, so we dont get background not rounded focus blueish tint
        .padding(10)
        .padding(.leading, 45)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white) //Text color
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color.clear)
                //.strokeBorder(Color.red, lineWidth: 1)
        )
    }
}


// MARK: CODEBLOCK
struct CodeBlock: View {
    
    @State var codeTextBlock: String
    @State var pressedCopy: Bool = false
    
    var body : some View {
        self.parseCodeBlock(rawText: codeTextBlock)
    }
    
    
    /// Method to parse syntaxis for ChatGPT response
    func parseCodeBlock(rawText: String) -> some View {
        /// Split and get both language and code
        let splitCodeblock = rawText.components(separatedBy: "```")
        var code = splitCodeblock[1]
        let language: String? = code.components(separatedBy: "\n")[0]
        if language != nil && !language!.isEmpty {
            /// Remove language from code. only first ocurrence
            if let range = language!.range(of:language!) {
                code = code.replacingCharacters(in: range, with:"")
            }
        }
        /// Prepare highlight
        let highlightr = Highlightr()
        highlightr!.setTheme(to: "paraiso-dark")
        // You can omit the second parameter to use automatic language detection.
        var highlightedCode = highlightr!.highlight(String(code))
        if language != nil && !language!.isEmpty{
            //highlightedCode = highlightr!.highlight(String(code), as: language!)
            //If malformed or unknown lang, then it fails, so better auto?
        }
        
        // Convert NSAttributedString to Attributed string to use on SwiftUI
        let a = try AttributedString(highlightedCode!)
        
        return VStack {
            Text(a)
                .lineSpacing(10)
                .scaleEffect(pressedCopy ? 1.05 : 1)
                .animation(pressedCopy
                           ? .default.speed(10)
                           : .spring()
                           , value: pressedCopy)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10) //to compensate the negative spacing of the
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            Button(action: {
                //Copy text
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(code, forType: .string)
                //Animate
                pressedCopy = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // your code here
                    pressedCopy = false
                }
                
            }, label: {
                    Image(systemName: "doc.on.doc")
                })
                .offset(
                    x: -10, y: 10
                )
            ,
            alignment: .topTrailing
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
            ContentView(currentState: Singleton.shared.currentState)
                .previewDisplayName("Main")
            
            CodeBlock(codeTextBlock: "```\nlet Swift = 1\n``` pèro hay itras `cosas` que lo ")
                .previewDisplayName("Code Block")
            
            //CodeInline(codeText: "`let Swift = 1`")
               // .previewDisplayName("Code Inline")
        }
        
    }
}
