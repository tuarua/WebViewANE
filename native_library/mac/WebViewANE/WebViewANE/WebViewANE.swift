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

    private static let ON_URL_CHANGE: String = "WebView.OnUrlChange"
    private static let ON_FINISH: String = "WebView.OnFinish"
    private static let ON_START: String = "WebView.OnStart"
    private static let ON_FAIL: String = "WebView.OnFail"
    private static let ON_JAVASCRIPT_RESULT: String = "WebView.OnJavascriptResult"
    private static let ON_PROGRESS: String = "WebView.OnProgress"
    private static let ON_PAGE_TITLE: String = "WebView.OnPageTitle"

    private func trace(value: String) {
        FREDispatchStatusEventAsync(self.dllContext, "[WebViewANE] " + value, "TRACE")
    }

    private func sendEvent(name: String, props: Dictionary<String, Any>?) {
        var value: String = ""
        if props != nil {
            do {
                let dic: Dictionary<String, Any> = props!
                let myjson = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                let theJSONText = NSString(data: myjson,
                        encoding: String.Encoding.utf8.rawValue)

                value = theJSONText! as String
            } catch {
                Swift.debugPrint(error.localizedDescription)
                print(error.localizedDescription)
            }
        }
        FREDispatchStatusEventAsync(self.dllContext, value, name)
    }

    func webView(_ myWebView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        var props: Dictionary<String, Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        sendEvent(name: WebViewANE.ON_URL_CHANGE, props: props);
    }

    func webView(_ myWebView: WKWebView, didCommit navigation: WKNavigation!) {
        var props: Dictionary<String, Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        sendEvent(name: WebViewANE.ON_START, props: props);
    }

    func webView(_ myWebView: WKWebView, didFinish navigation: WKNavigation!) {
        var props: Dictionary<String, Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        props["title"] = myWebView.title
        sendEvent(name: WebViewANE.ON_FINISH, props: props);
    }


    func webViewWebContentProcessDidTerminate(_ myWebView: WKWebView) {
        //outputText = "The Web Content Process is finished.\n"
        //trace(value: outputText)
    }

    func webView(_ myWebView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        var props: Dictionary<String, Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        sendEvent(name: WebViewANE.ON_FAIL, props: props);
    }

    func webView(_ myWebView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError: Error) {
        //var props: Dictionary<String, Any> = Dictionary()
        //props["url"] = myWebView.url!.absoluteString
        //sendEvent(name: WebViewANE.ON_FAIL, props: props);
    }

    func webView(_ myWebView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        var props: Dictionary<String, Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        sendEvent(name: WebViewANE.ON_URL_CHANGE, props: props);
    }

    func isSupported() -> FREObject? {
        var isSupported: Bool = false
        if #available(OSX 10.10, *) {
            isSupported = true
        }
        return aneHelper.getFreObject(bool: isSupported)
    }

    func allowsMagnification() -> FREObject? {
        if let wv = myWebView {
            return aneHelper.getFreObject(bool: wv.allowsMagnification)
        }

        return aneHelper.getFreObject(bool: true)
    }

    func getMagnification() -> FREObject? {
        if let wv = myWebView {
            return aneHelper.getFREObject(double: Double(wv.magnification))
        }
        return aneHelper.getFREObject(double: 1.0);
    }

    func setMagnification(argv: NSPointerArray) {
        if let wv = myWebView {
            let amount: Double = aneHelper.getNumber(freObject: argv.pointer(at: 0))
            let pt: CGPoint = aneHelper.getCGPoint(freObject: argv.pointer(at: 1))
            wv.setMagnification(CGFloat(amount), centeredAt: CGPoint.init(x: pt.x, y: pt.y))

        }
    }

    func addToStage() {
        if let mw = mainWindow {
            let view: NSView = mw.contentView!
            if let wv = myWebView {
                view.addSubview(wv)
            }
        }
    }

    func removeFromStage() {
        if let wv = myWebView {
            wv.removeFromSuperview()
        }
    }

    func evaluateJavaScript(argv: NSPointerArray) {
        let js: String = aneHelper.getString(freObject: argv.pointer(at: 0))
        if let wv = myWebView {
            wv.evaluateJavaScript(js, completionHandler: onJavascriptResult)
        }
    }

    func load(argv: NSPointerArray) {
        let url: String = aneHelper.getString(freObject: argv.pointer(at: 0))
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        if let wv = myWebView {
            wv.load(myRequest)
        }
    }

    func loadHTMLString(argv: NSPointerArray) {
        let html: String = aneHelper.getString(freObject: argv.pointer(at: 0))
        if let wv = myWebView {
            wv.loadHTMLString(html, baseURL: nil) //TODO
        }
    }

    func loadFileURL(argv: NSPointerArray) {
        let url: String = aneHelper.getString(freObject: argv.pointer(at: 0))
        let myURL = URL(string: url)
        let allowingReadAccessTo: String = aneHelper.getString(freObject: argv.pointer(at: 1))
        let accessURL = URL(string: allowingReadAccessTo)

        if let wv = myWebView {
            if #available(OSX 10.11, *) {
                wv.loadFileURL(myURL!, allowingReadAccessTo: accessURL!)
            } else {
                // Fallback on earlier versions
            }
        }

    }

    func reload() {
        if let wv = myWebView {
            wv.reload()
        }
    }

    func reloadFromOrigin() {
        if let wv = myWebView {
            wv.reloadFromOrigin()
        }
    }

    func stopLoading() {
        if let wv = myWebView {
            wv.stopLoading()
        }
    }

    func goBack() {
        if let wv = myWebView {
            wv.goBack()
        }
    }

    func goForward() {
        if let wv = myWebView {
            wv.goForward()
        }
    }


    func initWebView(argv: NSPointerArray) {
        var x = 0
        var y = 0
        var width = 800
        var height = 600

        x = aneHelper.getInt(freObject: argv.pointer(at: 0))
        y = aneHelper.getInt(freObject: argv.pointer(at: 1))
        width = aneHelper.getInt(freObject: argv.pointer(at: 2))
        height = aneHelper.getInt(freObject: argv.pointer(at: 3))


        let allWindows = NSApp.windows;
        if allWindows.count > 0 {
            mainWindow = allWindows[0]

            let configuration = WKWebViewConfiguration()
            let realY = (Int((mainWindow?.contentLayoutRect.height)!) - height) - y;

            let myRect: CGRect = CGRect.init(x: x, y: realY, width: width, height: height)

            myWebView = WKWebView(frame: myRect, configuration: configuration)
            myWebView?.translatesAutoresizingMaskIntoConstraints = false
            myWebView?.navigationDelegate = self
            myWebView?.uiDelegate = self


            myWebView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            myWebView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        }

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            var props: Dictionary<String, Any> = Dictionary()
            props["value"] = myWebView?.estimatedProgress
            sendEvent(name: WebViewANE.ON_PROGRESS, props: props);
        } else if (keyPath == "title") {
            if let t = myWebView?.title {
                if t != "" {
                    var props: Dictionary<String, Any> = Dictionary()
                    props["title"] = t
                    sendEvent(name: WebViewANE.ON_PAGE_TITLE, props: props);
                }
            }
        }
    }


    func onJavascriptResult(result: Any?, error: Error?) {
        var resultValue: String = ""
        var errorValue: String = ""

        if result != nil {
            Swift.debugPrint(result!)
            resultValue = result as! String
        }

        if error != nil {
            Swift.debugPrint(error!)
            errorValue = error!.localizedDescription

        }

        var props: Dictionary<String, Any> = Dictionary()

        props["result"] = resultValue
        props["error"] = errorValue
        sendEvent(name: WebViewANE.ON_JAVASCRIPT_RESULT, props: props);

    }


    func setFREContext(ctx: FREContext) {
        dllContext = ctx
        aneHelper.setFREContext(ctx: ctx)
    }

}


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





