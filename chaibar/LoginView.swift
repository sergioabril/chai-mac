//
//  LoginView.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 19/3/23.
//
import SwiftUI

struct LoginView: View {
    @ObservedObject var currentState: CurrentState
    
    @FocusState private var mailIsFocused : Bool

    @State var formEmail: String = ""
    
    @State var isBusy: Bool = false
    
    var body: some View {
        
        ZStack{
        
            Color.white
            
            VStack{
                /// ICON
                Spacer()
                    .frame(height: 30)
                Image("barIcon")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .rotationEffect(isBusy ? .degrees(360) : .degrees(0))
                    .animation(isBusy
                        ? .easeOut(duration: 5).repeatForever()
                        : .default,
                    value: isBusy)
                
                Spacer()
                    .frame(height: 30)
                
                /// Text
                Text("Type in the email you used to purchase a license, and we'll send you a code:")
                    .foregroundColor(.gray)
                
                ZStack{
                    /// Email
                    TextField("youremail@dot.com", text: $formEmail)
                        .placeholder(when: formEmail.isEmpty ) {
                            /// Custom placeholder modifier instead of txfield default
                            /// So we can customize it
                            Text("your@email.com")
                                .foregroundColor(Color.red)
                                .padding(.leading, 0)
                                .font(Font.system(size: 20, design: .rounded))
                                .opacity(mailIsFocused ? 0.5 : 1)
                        }
                        .focused($mailIsFocused)
                        .onSubmit {
                            print("On Submbmit Email\(formEmail)")
                            
                            sendMail(email: formEmail)
                        }
                        .disableAutocorrection(true)
                        .font(Font.system(size: 23, weight: .light, design: .rounded))
                        .textFieldStyle(MailTextFieldStyle())
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.black.opacity(0.2), lineWidth: 1)
                )
                
                
                Spacer()
                    
                
                Button("Send Login code", action: {
                    sendMail(email: formEmail)
                })
                .opacity(isBusy ? 0 : 1)
                .animation(.default, value: isBusy)
                
                Spacer()
                    .frame(height: 20)
            }
            .padding(20)
        }
        .background(.thinMaterial)
        .frame(width: 320, height: 350)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
       
    }
    
    
    
    func sendMail(email: String)
    {
        DebugHelper.log("sendMail: email=\(email)")

        if isBusy {
            return
        }
        
        isBusy = true
        Singleton.shared.serverRestSendEmailCode(forEmail: email) { success, message in
            
            DebugHelper.log("Response EMAIL: Success=\(success) - msg=\(message)")
            
            isBusy = false
        }
    }
}



// MARK: TextField Search Style
struct MailTextFieldStyle: TextFieldStyle {
    /// Custom stuff: https://stackoverflow.com/questions/73051258/swiftui-custom-textfield-with-focus-ring-on-macos
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(.plain) //Important, so we dont get background not rounded focus blueish tint
        .frame(maxWidth: .infinity)
        .foregroundColor(.black) //Text color
        //.padding(.leading, 10)
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(currentState: CurrentState())
    }
}
