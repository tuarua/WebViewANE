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
    //private var mainWindow: NSWindow?
    
    private var _x:Int = 0
    private var _y:Int = 0
    private var _width:Int = 800
    private var _height:Int = 600
    private var isAdded:Bool = false;

    private static let ON_FAIL: String = "WebView.OnFail"
    private static let ON_JAVASCRIPT_RESULT: String = "WebView.OnJavascriptResult"
    private static let ON_PROGRESS: String = "WebView.OnProgress"
    private static let ON_PROPERTY_CHANGE: String = "WebView.OnPropertyChange"

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
            }
        }
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
        sendEvent(name: WebViewANE.ON_FAIL, props: props);
    }

    func webView(_ myWebView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError: Error) {
        //var props: Dictionary<String, Any> = Dictionary()
        //props["url"] = myWebView.url!.absoluteString
        //sendEvent(name: WebViewANE.ON_FAIL, props: props);
        
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
                        aneHelper.setFREObjectProperty(
                                freObject: freCurrentItem, name: "url",
                                prop: aneHelper.getFreObject(string: ci.url.absoluteString)!)
                        aneHelper.setFREObjectProperty(
                                freObject: freCurrentItem, name: "title",
                                prop: aneHelper.getFreObject(string: ci.title)!)

                        aneHelper.setFREObjectProperty(
                                freObject: freCurrentItem, name: "initialURL",
                                prop: aneHelper.getFreObject(string: ci.initialURL.absoluteString)!)

                        aneHelper.setFREObjectProperty(freObject: freBackForwardList, name: "currentItem", prop: freCurrentItem)

                    }
                }

                var i = 0
                if let freBackList = aneHelper.createFREObject(className: "Vector.<com.tuarua.webview.BackForwardListItem>") {
                    for item in wv.backForwardList.backList {
                        if let freItem = aneHelper.createFREObject(className: "com.tuarua.webview.BackForwardListItem") {
                            aneHelper.setFREObjectProperty(
                                    freObject: freItem, name: "url",
                                    prop: aneHelper.getFreObject(string: item.url.absoluteString)!)
                            aneHelper.setFREObjectProperty(
                                    freObject: freItem, name: "title",
                                    prop: aneHelper.getFreObject(string: item.title)!)

                            aneHelper.setFREObjectProperty(
                                    freObject: freItem, name: "initialURL",
                                    prop: aneHelper.getFreObject(string: item.initialURL.absoluteString)!)

                            FRESetArrayElementAt(freBackList, UInt32(i), freItem);
                            i = i + 1
                        }
                    }
                    aneHelper.setFREObjectProperty(freObject: freBackForwardList, name: "backList", prop: freBackList)
                }

                i = 0
                if let freForwardList = aneHelper.createFREObject(className: "Vector.<com.tuarua.webview.BackForwardListItem>") {
                    for item in wv.backForwardList.forwardList {
                        if let freItem = aneHelper.createFREObject(className: "com.tuarua.webview.BackForwardListItem") {
                            aneHelper.setFREObjectProperty(
                                    freObject: freItem, name: "url",
                                    prop: aneHelper.getFreObject(string: item.url.absoluteString)!)
                            aneHelper.setFREObjectProperty(
                                    freObject: freItem, name: "title",
                                    prop: aneHelper.getFreObject(string: item.title)!)

                            aneHelper.setFREObjectProperty(
                                    freObject: freItem, name: "initialURL",
                                    prop: aneHelper.getFreObject(string: item.initialURL.absoluteString)!)

                            FRESetArrayElementAt(freForwardList, UInt32(i), freItem);
                            i = i + 1
                        }
                    }
                    aneHelper.setFREObjectProperty(freObject: freBackForwardList, name: "forwardList", prop: freForwardList)
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
       // trace(value: "addToStage");
        if let view = NSApp.mainWindow?.contentView {
         //   trace(value: "addSubview");
            view.addSubview(myWebView!)
            isAdded = true
            return
        }else { //allow for mainWindow not having been set yet on NSApp
            let allWindows = NSApp.windows;
            if allWindows.count > 0 {
                let mWin = allWindows[0]
                let view: NSView = mWin.contentView!
                if let wv = myWebView {
                   // trace(value: "addSubview");
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

    func evaluateJavaScript(argv: NSPointerArray) {
        let js: String = aneHelper.getString(freObject: argv.pointer(at: 0))
        if let wv = myWebView {
            wv.evaluateJavaScript(js, completionHandler: onJavascriptResult)
        }
    }
    
    func setPositionAndSize(argv: NSPointerArray){
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
        //TODO not 100% right ?
        
        if updateX || updateY {
            
            myWebView?.setFrameOrigin(NSPoint.init(x: _x, y: realY))
        }
        if updateWidth || updateHeight {
            myWebView?.setFrameSize(NSSize.init(width: _width, height: _height))
        }
        
        //trace(value: "setting x=\(_x), y=\(realY), width=\(_width), height=\(_height)");
    
        
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

    //TODO align with CEF version. Load the file in AIR and pass as HTML string
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
    
    func onFullScreen (argv: NSPointerArray) {
        let fullScreen:Bool = aneHelper.getBool(freObject: argv.pointer(at: 0))
        let tmpIsAdded = isAdded
        for win in NSApp.windows {
            if (fullScreen && win.canBecomeMain && win.className.contains("AIR_FullScreen")) {
                win.makeMain()
                break;
            } else if(!fullScreen && win.canBecomeMain && win.className.contains("AIR_PlayerContent")) {
                win.makeMain()
                win.orderFront(nil)
                break;
            }
        }
        
        if(tmpIsAdded){
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

    func initWebView(argv: NSPointerArray) {
        _x = aneHelper.getInt(freObject: argv.pointer(at: 0))
        _y = aneHelper.getInt(freObject: argv.pointer(at: 1))
        _width = aneHelper.getInt(freObject: argv.pointer(at: 2))
        _height = aneHelper.getInt(freObject: argv.pointer(at: 3))

        let allWindows = NSApp.windows;
        var mWin:NSWindow?
        if allWindows.count > 0 {
            if let win = NSApp.mainWindow {
                mWin = win
            }else { //allow for mainWindow not having been set yet on NSApp
                mWin = allWindows[0]
            }
            
            
            let configuration = WKWebViewConfiguration()
            let realY = (Int((mWin?.contentLayoutRect.height)!) - _height) - _y;
            
            let myRect: CGRect = CGRect.init(x: _x, y: realY, width: _width, height: _height)
            
            myWebView = WKWebView(frame: myRect, configuration: configuration)
            myWebView?.translatesAutoresizingMaskIntoConstraints = false
            myWebView?.navigationDelegate = self
            myWebView?.uiDelegate = self
            
            myWebView?.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
            myWebView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
            myWebView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
            myWebView?.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
            myWebView?.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
            myWebView?.addObserver(self, forKeyPath: "canGoForward", options: .new, context: nil)
            
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
            }else{
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

        sendEvent(name: WebViewANE.ON_PROPERTY_CHANGE, props: props);

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
