//
//  LoginView.swift
//  chaibar
//
//  Created by Sergio Abril Herrero on 19/3/23.
//
import SwiftUI


enum LoginViewPhase {
    case email
    case code
    case finished
}

struct LoginView: View {
    @ObservedObject var currentState: CurrentState
    
    @State var phase: LoginViewPhase = .email
    
    @State var formEmail: String = ""
    @State var formCode: String = ""

    @State var isBusy: Bool = false
    
    @State var errorMessage: String?// = "bla bla"
    
    var body: some View {
        
        ZStack{
        
            
            
            VStack{
                /// ICON
                Spacer()
                    .frame(height: 30)
                Image("barIcon_white")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .rotationEffect(isBusy ? .degrees(360) : .degrees(0))
                    .animation(isBusy
                        ? .easeOut(duration: 5).repeatForever()
                        : .default,
                    value: isBusy)
                
                Spacer()
                    .frame(height: 30)
                
                
                switch(phase)
                {
                case .email:
                    LoginViewPhaseEmail(sendEmail: {
                                            sendMail(email: formEmail)
                                        },
                                        formEmail: $formEmail,
                                        errorMessage: $errorMessage,
                                        isBusy: $isBusy)
                case .code:
                    LoginViewPhaseCode(validateCode: {
                                            validateCode(email: formEmail, code: formCode)
                                        }, formEmail: $formEmail,
                                       formCode: $formCode,
                                       errorMessage: $errorMessage,
                                       isBusy: $isBusy)
                default:
                    Text("Unexpected phase")
                }
                
                
                
                Spacer()
                    .frame(height: 20)
            }
            .padding(20)
        }
        //.background(Material.)
        .background(VisualEffectView(material: .ultraDark, blendingMode: .withinWindow))
        .frame(width: 320, height: 350)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
       
    }
    
    
    /// Method to send email
    func sendMail(email: String)
    {
        DebugHelper.log("sendMail: email=\(email)")

        if isBusy {
            return
        }
        
        errorMessage = nil
        
        isBusy = true
        Singleton.shared.serverRestSendEmailCode(forEmail: email) { success, message in
            
            DebugHelper.log("Response EMAIL: Success=\(success) - msg=\(message)")
            errorMessage = message
            isBusy = false
            
            
            if success {
                phase = .code
            }
        }
    }
    
    /// Validate codes
    func validateCode(email: String, code: String)
    {
        DebugHelper.log("validateCode: email=\(email) code=\(code)")

        if isBusy {
            return
        }
        
        errorMessage = nil
        
        isBusy = true
        
        Singleton.shared.serverRestValidateEmailCodes(forEmail: email, code: code) { success, message in
            DebugHelper.log("Response EMAIL+CODE: Success=\(success) - msg=\(message)")
            errorMessage = message
            isBusy = false
            
            if success == false {
                self.formCode = ""
            }else{

            }
        }

    }
}


/// VIEW INSERT EMAIL
struct LoginViewPhaseEmail: View {
    
    @FocusState private var mailIsFocused : Bool

    var sendEmail: () -> Void
    
    @Binding var formEmail: String
    @Binding var errorMessage: String?
    @Binding var isBusy: Bool
    
    var body: some View {
        Group {
            /// Text
            Text("Type in the email you used to purchase a license, and we'll send you a code:")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white.opacity(0.7))
            
            ZStack{
                /// Email
                TextField("", text: $formEmail)
                    .placeholder(when: formEmail.isEmpty ) {
                        /// Custom placeholder modifier instead of txfield default
                        /// So we can customize it
                        Text(verbatim: "your@email.com") //verbatim:  removes hyperlinks
                            .foregroundColor(Color.white)
                            .padding(.leading, 0)
                            .font(Font.system(size: 20, design: .rounded))
                            .opacity(mailIsFocused ? 0.3 : 0.9)
                    }
                    .focused($mailIsFocused)
                    .onSubmit {
                        print("On Submbmit Email\(formEmail)")
                        
                        sendEmail()
                    }
                    .disableAutocorrection(true)
                    .font(Font.system(size: 18, weight: .light, design: .rounded))
                    .textFieldStyle(MailTextFieldStyle())

            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .overlay(RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.black.opacity(0.2), lineWidth: 1)
            )
            
            //MESSAGE ERROR
            if errorMessage != nil {
                Spacer()
                    .frame(height: 5)
                ZStack{
                    Text(errorMessage!)
                        .foregroundColor(.white)
                        .font(Font.system(size: 10, weight: .light, design: .rounded))
                }
                Spacer()
            }else{
                Spacer()
            }
                
            
            Button("Send Login code", action: {
                sendEmail()
            })
            .disabled(isBusy)
            .opacity(isBusy ? 0 : 1)
            .animation(.default, value: isBusy)
        }
    }
}

/// VIEW INSERT CODE
struct LoginViewPhaseCode: View {
    
    @FocusState private var codeIsFocused : Bool

    var validateCode: () -> Void
    
    @Binding var formEmail: String
    @Binding var formCode: String
    @Binding var errorMessage: String?
    @Binding var isBusy: Bool
    
    var body: some View {
        Group {
            /// Text
            Text("Code sent to \(formEmail)\n(check spam as well)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white.opacity(0.7))
            
            ZStack{
                /// Email
                TextField("", text: $formCode)
                    .placeholder(when: formCode.isEmpty ) {
                        /// Custom placeholder modifier instead of txfield default
                        /// So we can customize it
                        Text("type-the-code")
                            .foregroundColor(Color.white)
                            .padding(.leading, 0)
                            .font(Font.system(size: 18, design: .rounded))
                            .opacity(codeIsFocused ? 0.3 : 0.9)
                    }
                    .lineLimit(1)
                    .focused($codeIsFocused)
                    .onSubmit {
                        print("On Submbmit codes\(formCode)")
                        
                        validateCode()
                    }
                    .disableAutocorrection(true)
                    .font(Font.system(size: 18, weight: .light, design: .rounded))
                    .textFieldStyle(MailTextFieldStyle())
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.black.opacity(0.2), lineWidth: 1)
            )
            
            //MESSAGE ERROR
            if errorMessage != nil {
                Spacer()
                    .frame(height: 5)
                ZStack{
                    Text(errorMessage!)
                        .foregroundColor(.white)
                        .font(Font.system(size: 10, weight: .light, design: .rounded))
                }
                Spacer()
            }else{
                Spacer()
            }
                
            
            Button("Validate Code", action: {
                validateCode()
            })
            .disabled(isBusy)
            .opacity(isBusy ? 0 : 1)
            .animation(.default, value: isBusy)
            
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
        .foregroundColor(.white) //Text color
        //.padding(.leading, 10)
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(currentState: CurrentState())
    }
}
