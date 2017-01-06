//
//  WebViewANE.swift
//  WebViewANE
//
//  Created by User on 05/01/2017.
//  Copyright © 2017 Tua Rua Ltd. All rights reserved.
//

import Cocoa
import Foundation
import WebKit

@objc class WebViewANE: NSObject, WKUIDelegate, WKNavigationDelegate {

    private var dllContext: FREContext!
    private let aneHelper = ANEHelper()
    private var myWebView: WKWebView?
    private var mainWindow: NSWindow?

    private static let ON_URL_CHANGE:String = "WebView.OnUrlChange"
    private static let ON_FINISH:String = "WebView.OnFinish"
    private static let ON_START:String = "WebView.OnStart"
    private static let ON_FAIL:String = "WebView.OnFail"

    var outputText: String = ""

    private func trace(value: String) {
        FREDispatchStatusEventAsync(self.dllContext, value, "TRACE")
    }

    private func sendEvent(name: String, props:Dictionary<String, Any>?) {
        Swift.debugPrint(name)
        var value:String = ""
        if props != nil {
            do {
                let dic:Dictionary<String,Any> = props!
                let myjson = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                let theJSONText = NSString(data: myjson,
                                           encoding: String.Encoding.utf8.rawValue)
                
                value = theJSONText! as String
                Swift.debugPrint("after let")
                
            } catch {
                Swift.debugPrint(error.localizedDescription)
                print(error.localizedDescription)
            }
        }
        FREDispatchStatusEventAsync(self.dllContext, value, name)
    }

    func webView(_ myWebView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        outputText = "1. The web content \(myWebView.url!) is loaded in the WebView.\n"
        trace(value: outputText);
        var props:Dictionary<String,Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        
        sendEvent(name: WebViewANE.ON_URL_CHANGE,props:props);
    }

    func webView(_ myWebView: WKWebView, didCommit navigation: WKNavigation!) {
        outputText = "2. The WebView begins to receive web content.\n"
        trace(value: outputText);
        var props:Dictionary<String,Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        sendEvent(name: WebViewANE.ON_START,props:props);
    }

    func webView(_ myWebView: WKWebView, didFinish navigation: WKNavigation!) {
        outputText = "3. The navigating to url \(myWebView.url!) finished.\n"
        trace(value: outputText);
        
        
        var props:Dictionary<String,Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString

        sendEvent(name: WebViewANE.ON_FINISH,props:props);
        //ON_FINISH
    }


    func webViewWebContentProcessDidTerminate(_ myWebView: WKWebView) {
        outputText = "The Web Content Process is finished.\n"
        trace(value: outputText)
    }

    func webView(_ myWebView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        outputText = "An error didFail occured.\n"
        trace(value: outputText)
        var props:Dictionary<String,Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        sendEvent(name: WebViewANE.ON_FAIL,props:props);

    }

    func webView(_ myWebView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError: Error) {
        outputText = "An error didFailProvisionalNavigation occured.\n"
        trace(value: outputText)
    }

    func webView(_ myWebView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        outputText = "The WebView received a server redirect. \(myWebView.url!) \n"
        trace(value: outputText)
        
        var props:Dictionary<String,Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        
        sendEvent(name: WebViewANE.ON_URL_CHANGE,props:props);

    }

    func addToStage() {
        if let mw = mainWindow {
            let view: NSView = mw.contentView!
            if let wv = myWebView {
                view.addSubview(wv)
            }
        }
    }

    func load(argv: NSPointerArray) {
        if let url: String = aneHelper.getIdObjectFromFREObject(freObject: argv.pointer(at: 0)) as? String {
            let myURL = URL(string: url)
            let myRequest = URLRequest(url: myURL!)
            if let wv = myWebView {
                wv.load(myRequest)
            }
        }
    }

    func initWebView(argv: NSPointerArray) {
        var x = 0
        var y = 0
        var width = 800
        var height = 600

        if let val = aneHelper.getIdObjectFromFREObject(freObject: argv.pointer(at: 0)) as? NSNumber {
            x = Int(val)
        }

        if let val = aneHelper.getIdObjectFromFREObject(freObject: argv.pointer(at: 1)) as? NSNumber {
            y = Int(val)
        }

        if let val = aneHelper.getIdObjectFromFREObject(freObject: argv.pointer(at: 2)) as? NSNumber {
            width = Int(val)
        }

        if let val = aneHelper.getIdObjectFromFREObject(freObject: argv.pointer(at: 3)) as? NSNumber {
            height = Int(val)
        }

        let allWindows = NSApp.windows;
        if allWindows.count > 0 {
            mainWindow = allWindows[0]

            trace(value: "\(mainWindow?.contentLayoutRect.width)")
            trace(value: "\(mainWindow?.contentLayoutRect.height)")

            trace(value: "\(mainWindow?.frame.origin.x)")
            trace(value: "\(mainWindow?.frame.origin.y)")

            let configuration = WKWebViewConfiguration()
            let realY = (Int((mainWindow?.contentLayoutRect.height)!) - height) - y;

            let myRect: CGRect = CGRect.init(x: x, y: realY, width: width, height: height)

            myWebView = WKWebView(frame: myRect, configuration: configuration)
            myWebView?.translatesAutoresizingMaskIntoConstraints = false
            myWebView?.navigationDelegate = self
            myWebView?.uiDelegate = self

        }

    }


    func setFREContext(ctx: FREContext) {
        dllContext = ctx
        aneHelper.setFREContext(ctx: ctx)
    }


}


//var webView: WKWebView!
//let webConfiguration = WKWebViewConfiguration()
//webView = WKWebView(frame: .zero, configuration: webConfiguration)
//webView.uiDelegate = self
//view = webView

//let myURL = URL(string: "https://www.apple.com")
//let myRequest = URLRequest(url: myURL!)
//webView.load(myRequest)





// topAnchor only available in version 10.11

/*
 [myWebView.topAnchor.constraint(equalTo: view.topAnchor),
 myWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
 myWebView.leftAnchor.constraint(equalTo: view.leftAnchor),
 myWebView.rightAnchor.constraint(equalTo: view.rightAnchor)].forEach  {
 anchor in
 anchor.isActive = true
 }  // end forEach
 */





