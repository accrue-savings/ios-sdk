import SwiftUI
import WebKit

import Foundation

import SwiftUI

public let referenceId: String
   public let email: String
   public let phoneNumber: String
   
   public init(referenceId: String, email: String, phoneNumber: String) {
       self.referenceId = referenceId
       self.email = email
       self.phoneNumber = phoneNumber
   }
}

#if os(iOS)
public struct WebView: UIViewRepresentable {
    public let url: URL
    public var contextData: ContextData?
    public var onSignIn: ((String) -> Void)?
      
    
    public init(url: URL, contextData: ContextData? = nil, onSignIn: ((String) -> Void)? = nil) {
           self.url = url
           self.contextData = contextData
           self.onSignIn = onSignIn
   }
    public class Coordinator: NSObject, WKScriptMessageHandler {
        var parent: WebView
          
        public init(parent: WebView) {
          self.parent = parent
        }
          
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
          print("Being called")
          print(message.name)
          if message.name == AccrueWebEvents.EventHandlerName, let userData = message.body as? String {
              parent.onSignIn?(userData)
          }
        }
    }
    public func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
    }
    @available(iOS 13.0, *)
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // Add the script message handler
        let userContentController = webView.configuration.userContentController
        userContentController.add(context.coordinator, name: AccrueWebEvents.EventHandlerName)

       
        // Inject JavaScript to set context data
        if let contextData = contextData {
            let contextDataScript = generateContextDataScript(contextData: contextData)
            print(contextDataScript)
            let userScript = WKUserScript(source: contextDataScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            userContentController.addUserScript(userScript)
        }
       
        return webView
    }
    @available(iOS 13.0, *)
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
      
        uiView.load(request)
    }
    // Generate JavaScript for Context Data
    private func generateContextDataScript(contextData: ContextData) -> String {
        return """
              window["\(AccrueWebEvents.EventHandlerName)"] = {
                    "contextData": {
                        "referenceId": "\(contextData.referenceId)",
                        "email": "\(contextData.email)",
                        "phoneNumber": "\(contextData.phoneNumber)"
                    }
              };
              """
    }
}
#endif
