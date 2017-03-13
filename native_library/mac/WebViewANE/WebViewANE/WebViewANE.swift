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
    private var myWebView: WKWebView?
    static var escListener: Any?

    private var _initialUrl: String = ""
    private var _x: Int = 0
    private var _y: Int = 0
    private var _width: Int = 800
    private var _height: Int = 600
    private var _userAgent: String?;
    private var isAdded: Bool = false;

    private static let ON_FAIL: String = "WebView.OnFail"
    private static let ON_ESC_KEY: String = "WebView.OnEscKey"
    private static let ON_PROPERTY_CHANGE: String = "WebView.OnPropertyChange"
    private static let JS_CALLBACK_EVENT: String = "TRWV.js.CALLBACK";
    private static let AS_CALLBACK_EVENT: String = "TRWV.as.CALLBACK";

    private var configuration: WKWebViewConfiguration = WKWebViewConfiguration()
    private var userController: WKUserContentController = WKUserContentController()

    private func sendEvent(name: String, value: String) {
        do {
            try context.dispatchStatusEventAsync(code: value, level: name)
        } catch {
        }
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
        sendEvent(name: WebViewANE.ON_FAIL, value: json.description)
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
        return try! FREObject.newObject(bool: isSupported)
    }

    func allowsMagnification() -> FREObject? {
        if let wv = myWebView {
            return try! FREObject.newObject(bool: wv.allowsMagnification)
        }
        return try! FREObject.newObject(bool: true)
    }

    func backForwardList() -> FREObject? {
        if let wv = myWebView {
            do {
                if let freBackForwardList = try FREObject.newObject(className: "com.tuarua.webview.BackForwardList", args: nil) {
                    if let ci = wv.backForwardList.currentItem {
                        if let freCurrentItem = try FREObject.newObject(className: "com.tuarua.webview.BackForwardListItem", args: nil) {
                            try freCurrentItem.setProperty(name: "url", prop: FREObject.newObject(string: ci.url.absoluteString))
                            try freCurrentItem.setProperty(name: "title", prop: FREObject.newObject(string: ci.title!))
                            try freCurrentItem.setProperty(name: "initialURL", prop: FREObject.newObject(string: ci.initialURL.absoluteString))

                            try freBackForwardList.setProperty(name: "currentItem", prop: freCurrentItem)
                        }

                        var i = 0
                        if let freBackList = try FREObject.newObject(className: "Vector.<com.tuarua.webview.BackForwardListItem>", args: nil) {
                            for item in wv.backForwardList.backList {
                                if let freItem = try FREObject.newObject(className: "com.tuarua.webview.BackForwardListItem", args: nil) {
                                    try freItem.setProperty(name: "url", prop: FREObject.newObject(string: item.url.absoluteString))
                                    try freItem.setProperty(name: "title", prop: FREObject.newObject(string: item.title!))
                                    try freItem.setProperty(name: "initialURL", prop: FREObject.newObject(string: item.initialURL.absoluteString))
                                    try freBackList.setObjectAt(index: UInt(i), object: freItem)
                                    i = i + 1
                                }
                            }
                            try freBackForwardList.setProperty(name: "backList", prop: freBackList)
                        }

                        i = 0
                        if let freForwardList = try FREObject.newObject(className: "Vector.<com.tuarua.webview.BackForwardListItem>", args: nil) {
                            for item in wv.backForwardList.forwardList {
                                if let freItem = try FREObject.newObject(className: "com.tuarua.webview.BackForwardListItem", args: nil) {
                                    try freItem.setProperty(name: "url", prop: FREObject.newObject(string: item.url.absoluteString))
                                    try freItem.setProperty(name: "title", prop: FREObject.newObject(string: item.title!))
                                    try freItem.setProperty(name: "initialURL", prop: FREObject.newObject(string: item.initialURL.absoluteString))
                                    try freForwardList.setObjectAt(index: UInt(i), object: freItem)
                                    i = i + 1
                                }
                            }
                            try freBackForwardList.setProperty(name: "forwardList", prop: freForwardList)

                        }

                    }
                    return freBackForwardList
                }
            } catch let e as FREError {
                e.printStackTrace(#file, #line, #column)
            } catch {
            }
        }
        return nil

    }

    func go(argv: NSPointerArray) {
        do {
            if let inFRE0 = argv.pointer(at: 0) {
                let offset: Int = try inFRE0.getAsInt()
                if let wv = myWebView {
                    wv.go(to: wv.backForwardList.item(at: offset)!)
                }
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }
    }

    func getMagnification() -> FREObject? {
        do {
            if let wv = myWebView {
                return try FREObject.newObject(double: Double(wv.magnification))
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }
        return try! FREObject.newObject(double: 1.0)
    }

    func setMagnification(argv: NSPointerArray) {
        do {
            if let inFRE0 = argv.pointer(at: 0), let inFRE1 = argv.pointer(at: 1) {
                let magnification = try inFRE0.getAsCGFloat()
                let centeredAt = try inFRE1.getAsCGPoint()

                if let wv = myWebView {
                    wv.setMagnification(magnification, centeredAt: centeredAt)
                }
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
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
        var updateWidth = false;
        var updateHeight = false;
        var updateX = false;
        var updateY = false;
        do {
            if let inFRE0 = argv.pointer(at: 0), let inFRE1 = argv.pointer(at: 1), let inFRE2 = argv.pointer(at: 2),
               let inFRE3 = argv.pointer(at: 3) {

                let tmp_x: Int = try inFRE0.getAsInt()
                let tmp_y: Int = try inFRE1.getAsInt()
                let tmp_width: Int = try inFRE2.getAsInt()
                let tmp_height: Int = try inFRE3.getAsInt()

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

            }

        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
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
        do {
            if let inFRE0 = argv.pointer(at: 0) {
                let url: String = try inFRE0.getAsString()
                if !url.isEmpty {
                    let myURL = URL(string: url)
                    let myRequest = URLRequest(url: myURL!)
                    if let wv = myWebView {
                        wv.load(myRequest)
                    }
                }
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }

    }

    func loadHTMLString(argv: NSPointerArray) {
        do {
            if let inFRE0 = argv.pointer(at: 0) {
                let html: String = try inFRE0.getAsString()
                if let wv = myWebView {
                    wv.loadHTMLString(html, baseURL: nil) //TODO
                }
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }
    }

    func loadFileURL(argv: NSPointerArray) {
        do {
            if let inFRE0 = argv.pointer(at: 0), let inFRE1 = argv.pointer(at: 1) {
                let url: String = try inFRE0.getAsString()
                let myURL = URL(string: url)
                let allowingReadAccessTo: String = try inFRE1.getAsString()
                let accessURL = URL(string: allowingReadAccessTo)
                if let wv = myWebView {
                    if #available(OSX 10.11, *) {
                        wv.loadFileURL(myURL!, allowingReadAccessTo: accessURL!)
                    } else {
                        // Fallback on earlier versions //TODO
                    }
                }
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }


    }

    func onFullScreen(argv: NSPointerArray) {
        do {
            if let inFRE0 = argv.pointer(at: 0) {
                let fullScreen: Bool = try inFRE0.getAsBool()
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

        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {}

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

    func evaluateJavaScript(argv: NSPointerArray) {
        if let wv = myWebView {
            do {
                if let inFRE0 = argv.pointer(at: 0) {
                    let js = try inFRE0.getAsString()
                    if let inFRE1 = argv.pointer(at: 1) {
                        //test this
                        let callback = try inFRE1.getAsString()
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
                            self.sendEvent(name: WebViewANE.AS_CALLBACK_EVENT, value: json.description)
                        })
                    } else {
                        wv.evaluateJavaScript(js, completionHandler: nil)
                    }


                }
            } catch let e as FREError {
                e.printStackTrace(#file, #line, #column)
            } catch {}
        }

    }

    func callJavascriptFunction(argv: NSPointerArray) {
        evaluateJavaScript(argv: argv)
    }

    func injectScript(argv: NSPointerArray) {
        do {
            if let inFRE0: FREObject = argv.pointer(at: 0) {
                let injectCode: String = try inFRE0.getAsString()
                let userScript = WKUserScript.init(source: injectCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                userController.addUserScript(userScript)
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {}
    }

    /*! @abstract Invoked when a script message is received from a webpage.
     @param userContentController The user content controller invoking the
     delegate method.
     @param message The script message received.
     */
    @available(OSX 10.10, *)
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody: NSDictionary = message.body as? NSDictionary {
            let json = JSON(messageBody);
            sendEvent(name: WebViewANE.JS_CALLBACK_EVENT, value: json.description);
        }
    }

    func initWebView(argv: NSPointerArray) {
        do {
            if let initialUrlFRE: FREObject = argv.pointer(at: 0) {
                _initialUrl = try initialUrlFRE.getAsString()
            }

            if let inFRE1 = argv.pointer(at: 1), let inFRE2 = argv.pointer(at: 2), let inFRE3 = argv.pointer(at: 3),
               let inFRE4 = argv.pointer(at: 4) {
                _x = try inFRE1.getAsInt()
                _y = try inFRE2.getAsInt()
                _width = try inFRE3.getAsInt()
                _height = try inFRE4.getAsInt()
            }

        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
            return
        } catch {
            return
        }

        let allWindows = NSApp.windows;
        var mWin: NSWindow?
        if allWindows.count > 0 {
            if let win = NSApp.mainWindow {
                mWin = win
            } else {
                //allow for mainWindow not having been set yet on NSApp
                mWin = allWindows[0]
            }

            do {
                if let settingsFRE: FREObject = argv.pointer(at: 5) {
                    if let settingsWK = try settingsFRE.getProperty(name: "webkit") {
                        if let plugInsEnabled: Bool = try settingsWK.getProperty(name: "plugInsEnabled")?.getAsBool() {
                            configuration.preferences.plugInsEnabled = plugInsEnabled
                        }
                        if let javaScriptEnabled: Bool = try settingsWK.getProperty(name: "javaScriptEnabled")?.getAsBool() {
                            configuration.preferences.javaScriptEnabled = javaScriptEnabled
                        }
                        if let javaScriptCanOpenWindowsAutomatically: Bool =
                        try settingsWK.getProperty(name: "javaScriptCanOpenWindowsAutomatically")?.getAsBool() {
                            configuration.preferences.javaScriptCanOpenWindowsAutomatically = javaScriptCanOpenWindowsAutomatically
                        }
                        if let javaEnabled: Bool = try settingsWK.getProperty(name: "javaEnabled")?.getAsBool() {
                            configuration.preferences.javaEnabled = javaEnabled
                        }
                        if let minimumFontSize: CGFloat = try settingsWK.getProperty(name: "minimumFontSize")?.getAsCGFloat() {
                            configuration.preferences.minimumFontSize = minimumFontSize
                        }
                    }

                    if #available(OSX 10.11, *) {
                        if let userAgent: String = try settingsFRE.getProperty(name: "userAgent")?.getAsString() {
                            _userAgent = userAgent
                        }
                    }

                }
            } catch let e as FREError {
                e.printStackTrace(#file, #line, #column)
            } catch {
            }

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
                    if let userAgent = _userAgent {
                        wv.customUserAgent = userAgent
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
        sendEvent(name: WebViewANE.ON_PROPERTY_CHANGE, value: json.description)

    }

    func setFREContext(ctx: FREContext) {
        context = ctx
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
