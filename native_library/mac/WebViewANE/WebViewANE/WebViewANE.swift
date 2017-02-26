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

@objc class WebViewANE: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    private var dllContext: FREContext!
    private let aneHelper = ANEHelper()
    private var myWebView: WKWebView?
    static var escListener: Any?

    private var _initialUrl: String = ""
    private var _x: Int = 0
    private var _y: Int = 0
    private var _width: Int = 800
    private var _height: Int = 600
    private var isAdded: Bool = false;
    
    private static let ON_FAIL: String = "WebView.OnFail"
    private static let ON_ESC_KEY: String = "WebView.OnEscKey"
    private static let ON_PROPERTY_CHANGE: String = "WebView.OnPropertyChange"
    private static let JS_CALLBACK_EVENT:String = "TRWV.js.CALLBACK";
    private static let AS_CALLBACK_EVENT:String  = "TRWV.as.CALLBACK";
    
    private var configuration:WKWebViewConfiguration = WKWebViewConfiguration()
    private var userController:WKUserContentController = WKUserContentController()
    private func trace(value: String) {
        FREDispatchStatusEventAsync(self.dllContext, "[WebViewANE] " + value, "TRACE")
    }
    private func sendEvent(name: String, value: String) {
        FREDispatchStatusEventAsync(self.dllContext, value, name)
    }
    
    func webView(_ myWebView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    func webView(_ myWebView: WKWebView, didCommit navigation: WKNavigation!) {
    }

    func webView(_ myWebView: WKWebView, didFinish navigation: WKNavigation!) {
    }


    func webViewWebContentProcessDidTerminate(_ myWebView: WKWebView) {
        //outputText = "The Web Content Process is finished.\n"
        //trace(value: outputText)
    }

    func webView(_ myWebView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        var props: Dictionary<String, Any> = Dictionary()
        props["url"] = myWebView.url!.absoluteString
        props["errorCode"] = 0
        props["errorText"] = withError.localizedDescription
        let json = JSON(props)
        sendEvent(name: WebViewANE.ON_FAIL, value: json.description )
    }

    func webView(_ myWebView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError: Error) {
    }

    func webView(_ myWebView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
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

    func backForwardList() -> FREObject? {

        if let wv = myWebView {
            if let freBackForwardList = aneHelper.createFREObject(className: "com.tuarua.webview.BackForwardList") {

                if let ci = wv.backForwardList.currentItem {
                    if let freCurrentItem = aneHelper.createFREObject(className: "com.tuarua.webview.BackForwardListItem") {
                        aneHelper.setProperty(
                                freObject: freCurrentItem, name: "url",
                                prop: aneHelper.getFreObject(string: ci.url.absoluteString)!)
                        aneHelper.setProperty(
                                freObject: freCurrentItem, name: "title",
                                prop: aneHelper.getFreObject(string: ci.title)!)

                        aneHelper.setProperty(
                                freObject: freCurrentItem, name: "initialURL",
                                prop: aneHelper.getFreObject(string: ci.initialURL.absoluteString)!)

                        aneHelper.setProperty(freObject: freBackForwardList, name: "currentItem", prop: freCurrentItem)

                    }
                }

                var i = 0
                if let freBackList = aneHelper.createFREObject(className: "Vector.<com.tuarua.webview.BackForwardListItem>") {
                    for item in wv.backForwardList.backList {
                        if let freItem = aneHelper.createFREObject(className: "com.tuarua.webview.BackForwardListItem") {
                            aneHelper.setProperty(
                                    freObject: freItem, name: "url",
                                    prop: aneHelper.getFreObject(string: item.url.absoluteString)!)
                            aneHelper.setProperty(
                                    freObject: freItem, name: "title",
                                    prop: aneHelper.getFreObject(string: item.title)!)

                            aneHelper.setProperty(
                                    freObject: freItem, name: "initialURL",
                                    prop: aneHelper.getFreObject(string: item.initialURL.absoluteString)!)

                            FRESetArrayElementAt(freBackList, UInt32(i), freItem);
                            i = i + 1
                        }
                    }
                    aneHelper.setProperty(freObject: freBackForwardList, name: "backList", prop: freBackList)
                }

                i = 0
                if let freForwardList = aneHelper.createFREObject(className: "Vector.<com.tuarua.webview.BackForwardListItem>") {
                    for item in wv.backForwardList.forwardList {
                        if let freItem = aneHelper.createFREObject(className: "com.tuarua.webview.BackForwardListItem") {
                            aneHelper.setProperty(
                                    freObject: freItem, name: "url",
                                    prop: aneHelper.getFreObject(string: item.url.absoluteString)!)
                            aneHelper.setProperty(
                                    freObject: freItem, name: "title",
                                    prop: aneHelper.getFreObject(string: item.title)!)

                            aneHelper.setProperty(
                                    freObject: freItem, name: "initialURL",
                                    prop: aneHelper.getFreObject(string: item.initialURL.absoluteString)!)

                            FRESetArrayElementAt(freForwardList, UInt32(i), freItem);
                            i = i + 1
                        }
                    }
                    aneHelper.setProperty(freObject: freBackForwardList, name: "forwardList", prop: freForwardList)
                }
                return freBackForwardList
            }
        }
        return nil

    }

    func go(argv: NSPointerArray) {
        let offset: Int = aneHelper.getInt(freObject: argv.pointer(at: 0))
        if let wv = myWebView {
            wv.go(to: wv.backForwardList.item(at: offset)!)
        }
    }

    func getMagnification() -> FREObject? {
        if let wv = myWebView {
            return aneHelper.getFREObject(double: Double(wv.magnification))
        }
        return aneHelper.getFREObject(double: 1.0);
    }

    func setMagnification(argv: NSPointerArray) {
        if let wv = myWebView {
            wv.setMagnification(aneHelper.getCGFloat(freObject: argv.pointer(at: 0)),
                    centeredAt: aneHelper.getCGPoint(freObject: argv.pointer(at: 1)))
        }
    }

    func addToStage() {
        if let view = NSApp.mainWindow?.contentView {
            view.addSubview(myWebView!)
            isAdded = true
            return
        } else {
            //allow for mainWindow not having been set yet on NSApp
            let allWindows = NSApp.windows;
            if allWindows.count > 0 {
                let mWin = allWindows[0]
                let view: NSView = mWin.contentView!
                if let wv = myWebView {
                    view.addSubview(wv)
                    isAdded = true
                    return
                }
            }
        }
    }

    func removeFromStage() {
        if let wv = myWebView {
            wv.removeFromSuperview()
            isAdded = false
        }
    }

    func setPositionAndSize(argv: NSPointerArray) {
        let tmp_x = aneHelper.getInt(freObject: argv.pointer(at: 0))
        let tmp_y = aneHelper.getInt(freObject: argv.pointer(at: 1))
        let tmp_width = aneHelper.getInt(freObject: argv.pointer(at: 2))
        let tmp_height = aneHelper.getInt(freObject: argv.pointer(at: 3))
        var updateWidth = false;
        var updateHeight = false;
        var updateX = false;
        var updateY = false;
        if (tmp_width != _width) {
            _width = tmp_width;
            updateWidth = true;
        }
        if (tmp_height != _height) {
            _height = tmp_height;
            updateHeight = true;
        }
        if (tmp_x != _x) {
            _x = tmp_x;
            updateX = true;
        }
        if (tmp_y != _y) {
            _y = tmp_y;
            updateY = true;
        }

        let realY = (Int((NSApp.mainWindow?.contentLayoutRect.height)!) - _height) - _y;
        if updateX || updateY {
            myWebView?.setFrameOrigin(NSPoint.init(x: _x, y: realY))
        }
        if updateWidth || updateHeight {
            myWebView?.setFrameSize(NSSize.init(width: _width, height: _height))
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
                // Fallback on earlier versions //TODO
            }
        }

    }

    func onFullScreen(argv: NSPointerArray) {
        let fullScreen: Bool = aneHelper.getBool(freObject: argv.pointer(at: 0))
        let tmpIsAdded = isAdded
        for win in NSApp.windows {
            if (fullScreen && win.canBecomeMain && win.className.contains("AIR_FullScreen")) {
                win.makeMain()
                if (WebViewANE.escListener == nil) {
                    WebViewANE.escListener = NSEvent.addLocalMonitorForEvents(matching: [.keyUp]) { (event: NSEvent) -> NSEvent? in
                        let theX = Int(event.locationInWindow.x)
                        let theY = Int(event.locationInWindow.y)
                        let realY = (Int(win.contentLayoutRect.height) - self._height) - self._y;
                        if (event.keyCode == 53 && theX > self._x && theX < (self._width - self._x)
                            && theY > realY && theY < (realY + self._height)) {
                            self.sendEvent(name: WebViewANE.ON_ESC_KEY, value: "")
                        }
                        return event
                    }
                }
                break;
            } else if (!fullScreen && win.canBecomeMain && win.className.contains("AIR_PlayerContent")) {
                win.makeMain()
                win.orderFront(nil)
                break;
            }
        }
        
        if (tmpIsAdded) {
            removeFromStage();
            addToStage();
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

    func evaluateJavaScript(argv: NSPointerArray) { //replicated, possibly refactor to remove
        if let wv = myWebView {
            let js = aneHelper.getString(freObject: argv.pointer(at: 0))
            var callback: String? = nil
            var callbackType: FREObjectType = FRE_TYPE_NULL;
            FREGetObjectType(argv.pointer(at: 1), &callbackType);
            
            if FRE_TYPE_STRING == callbackType {
                callback = aneHelper.getString(freObject: argv.pointer(at: 1))
                wv.evaluateJavaScript(js, completionHandler: { (result: Any?, error: Error?) -> Void in
                    var props: Dictionary<String, Any> = Dictionary()
                    props["callbackName"] = callback
                    props["message"] = ""
                    if error != nil {
                        props["success"] = false
                        props["error"] = error.debugDescription
                    } else {
                        props["error"] = ""
                        props["success"] = true
                    }
                    props["result"] = result
                    let json = JSON(props)
                    self.sendEvent(name: WebViewANE.AS_CALLBACK_EVENT, value: json.description )
                })
            }else{
                wv.evaluateJavaScript(js, completionHandler: nil)
            }
            
        }
    }
    
    func callJavascriptFunction(argv: NSPointerArray) {
        if let wv = myWebView {
            let js = aneHelper.getString(freObject: argv.pointer(at: 0))
            aneHelper.printObjectType(freObject: argv.pointer(at: 1))
            var callback: String? = nil
            var callbackType: FREObjectType = FRE_TYPE_NULL;
            FREGetObjectType(argv.pointer(at: 1), &callbackType);
            
            
            if FRE_TYPE_STRING == callbackType {
                callback = aneHelper.getString(freObject: argv.pointer(at: 1))
                wv.evaluateJavaScript(js, completionHandler: { (result: Any?, error: Error?) -> Void in
                    var props: Dictionary<String, Any> = Dictionary()
                    props["callbackName"] = callback
                    props["message"] = ""
                    if error != nil {
                        props["success"] = false
                        props["error"] = error.debugDescription
                    } else {
                        props["error"] = ""
                        props["success"] = true
                    }
                    props["result"] = result
                    let json = JSON(props)
                    self.sendEvent(name: WebViewANE.AS_CALLBACK_EVENT, value: json.description )
                })
            } else {
                wv.evaluateJavaScript(js, completionHandler: nil)
            }
        }
    }
    
    func injectScript(argv: NSPointerArray) {
        var codeType: FREObjectType = FRE_TYPE_NULL;
        FREGetObjectType(argv.pointer(at: 0), &codeType);
        
        var scriptUrlType: FREObjectType = FRE_TYPE_NULL;
        FREGetObjectType(argv.pointer(at: 0), &scriptUrlType);

        if (FRE_TYPE_NULL != codeType) {
            let injectCode = aneHelper.getString(freObject: argv.pointer(at: 0));
            let userScript =  WKUserScript.init(source: injectCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            userController.addUserScript(userScript)
        }
    }
    
    /*! @abstract Invoked when a script message is received from a webpage.
     @param userContentController The user content controller invoking the
     delegate method.
     @param message The script message received.
     */
    @available(OSX 10.10, *)
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody:NSDictionary = message.body as? NSDictionary{
            let json = JSON(messageBody);
            sendEvent(name: WebViewANE.JS_CALLBACK_EVENT, value: json.description); 
        }
    }

    func initWebView(argv: NSPointerArray) {
        _initialUrl = aneHelper.getString(freObject: argv.pointer(at: 0))
        _x = aneHelper.getInt(freObject: argv.pointer(at: 1))
        _y = aneHelper.getInt(freObject: argv.pointer(at: 2))
        _width = aneHelper.getInt(freObject: argv.pointer(at: 3))
        _height = aneHelper.getInt(freObject: argv.pointer(at: 4))

        let allWindows = NSApp.windows;
        var mWin: NSWindow?
        if allWindows.count > 0 {
            if let win = NSApp.mainWindow {
                mWin = win
            } else {
                //allow for mainWindow not having been set yet on NSApp
                mWin = allWindows[0]
            }

            let settingsFRE = aneHelper.getProperty(freObject: argv.pointer(at: 5), propertyName: "webkit")
            configuration.preferences.plugInsEnabled = aneHelper.getBool(freObject:
                aneHelper.getProperty(freObject: settingsFRE, propertyName: "plugInsEnabled"))
            
            configuration.preferences.javaScriptEnabled = aneHelper.getBool(freObject:
                aneHelper.getProperty(freObject: settingsFRE, propertyName: "javaScriptEnabled"))
            
            configuration.preferences.javaScriptCanOpenWindowsAutomatically = aneHelper.getBool(freObject:
                aneHelper.getProperty(freObject: settingsFRE,
                                               propertyName: "javaScriptCanOpenWindowsAutomatically"))
            
            configuration.preferences.javaEnabled = aneHelper.getBool(freObject:
                aneHelper.getProperty(freObject: settingsFRE, propertyName: "javaEnabled"))
            
            configuration.preferences.minimumFontSize = aneHelper.getCGFloat(freObject:
                aneHelper.getProperty(freObject: settingsFRE, propertyName: "minimumFontSize"))

            
            userController.add(self, name: "webViewANE")
            configuration.userContentController = userController;
            
            let realY = (Int((mWin?.contentLayoutRect.height)!) - _height) - _y;
            let myRect: CGRect = CGRect.init(x: _x, y: realY, width: _width, height: _height)

            myWebView = WKWebView(frame: myRect, configuration: configuration)
            if let wv = myWebView {
                wv.translatesAutoresizingMaskIntoConstraints = false
                wv.navigationDelegate = self
                wv.uiDelegate = self
                if #available(OSX 10.11, *) {
                    var userAgentAS: FREObject? = nil;
                    userAgentAS = aneHelper.getProperty(freObject: argv.pointer(at: 5), propertyName: "userAgent");
                    var userAgentType: FREObjectType = FRE_TYPE_NULL;
                    FREGetObjectType(userAgentAS, &userAgentType);
                    if FRE_TYPE_STRING == userAgentType {
                       wv.customUserAgent = aneHelper.getString(freObject: userAgentAS)
                    }
                }

                wv.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
                wv.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
                wv.addObserver(self, forKeyPath: "title", options: .new, context: nil)
                wv.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
                wv.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
                wv.addObserver(self, forKeyPath: "canGoForward", options: .new, context: nil)
                if !_initialUrl.isEmpty {
                    let myURL = URL(string: _initialUrl)
                    let myRequest = URLRequest(url: myURL!)
                    wv.load(myRequest)
                }

            }
        }


    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        var props: Dictionary<String, Any> = Dictionary()
        switch keyPath! {
        case "estimatedProgress":
            props["propName"] = "estimatedProgress"
            props["value"] = myWebView?.estimatedProgress
            break;
        case "URL":
            if let val = myWebView?.url?.absoluteString {
                if val != "" {
                    props["propName"] = "url"
                    props["value"] = val
                } else {
                    return
                }
            } else {
                return
            }
            break;
        case "title":
            if let val = myWebView?.title {
                if val != "" {
                    props["propName"] = "title"
                    props["value"] = val
                }
            }
            break;
        case "canGoBack":
            props["propName"] = "canGoBack"
            props["value"] = myWebView?.canGoBack
            break;
        case "canGoForward":
            props["propName"] = "canGoForward"
            props["value"] = myWebView?.canGoForward
            break;
        case "loading":
            props["propName"] = "isLoading"
            props["value"] = myWebView?.isLoading
            break;

        default:
            props["propName"] = keyPath
            props["value"] = nil
            break;
        }

        let json = JSON(props)
        sendEvent(name: WebViewANE.ON_PROPERTY_CHANGE, value: json.description )

    }

    func setFREContext(ctx: FREContext) {
        dllContext = ctx
        aneHelper.setFREContext(ctx: ctx)
    }

}

/*
 screenShot
 - (UIImage *)snapshot:(UIView *)view
 {
 UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
 [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
 UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return image;
 }
 */
