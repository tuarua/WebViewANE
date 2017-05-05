/*@copyright The code is licensed under the[MIT
 License](http://opensource.org/licenses/MIT):
 
 Copyright © 2017 -  Tua Rua Ltd.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files(the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions :
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.*/

import Foundation
import WebKit

#if os(iOS)
import FRESwift
#else
import Cocoa
#endif

@objc class WebViewANE: FRESwiftController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {

    private var myWebView: WKWebView?
    static var escListener: Any?
    private var _initialUrl: String = ""
    private var _x: CGFloat = 0
    private var _y: CGFloat = 0
    private var _width: CGFloat = 800
    private var _height: CGFloat = 600
    private var _userAgent: String?

    public enum PopupBehaviour: Int {
        case block = 0
        case newWindow
        case sameWindow
    }

    private var _popupBehaviour: PopupBehaviour = PopupBehaviour.newWindow;
#if os(iOS)
    private var _bgColor: UIColor = UIColor.white
#else
    private var _popup: Popup!
#endif
    private var isAdded: Bool = false
    private static let ON_FAIL: String = "WebView.OnFail"
    private static let ON_ESC_KEY: String = "WebView.OnEscKey"
    private static let ON_PROPERTY_CHANGE: String = "WebView.OnPropertyChange"
    private static let JS_CALLBACK_EVENT: String = "TRWV.js.CALLBACK"
    private static let AS_CALLBACK_EVENT: String = "TRWV.as.CALLBACK"
    private var configuration: WKWebViewConfiguration = WKWebViewConfiguration()
    private var userController: WKUserContentController = WKUserContentController()


    // must have this function !!
    // Must set const numFunctions in WebViewANE.m to the length of this Array
    func getFunctions() -> Array<String> {

        functionsToSet["reload"] = reload
        functionsToSet["load"] = load
        functionsToSet["init"] = initWebView
        functionsToSet["isSupported"] = isSupported
        functionsToSet["addToStage"] = addToStage
        functionsToSet["removeFromStage"] = removeFromStage
        functionsToSet["setBackgroundColor"] = setBackgroundColor
        functionsToSet["loadHTMLString"] = loadHTMLString
        functionsToSet["loadFileURL"] = loadFileURL
        functionsToSet["onFullScreen"] = onFullScreen
        functionsToSet["reloadFromOrigin"] = reloadFromOrigin
        functionsToSet["stopLoading"] = stopLoading
        functionsToSet["backForwardList"] = backForwardList
        functionsToSet["go"] = go
        functionsToSet["goBack"] = goBack
        functionsToSet["goForward"] = goForward
        functionsToSet["allowsMagnification"] = allowsMagnification
        functionsToSet["getMagnification"] = getMagnification
        functionsToSet["setMagnification"] = setMagnification
        functionsToSet["setPositionAndSize"] = setPositionAndSize
        functionsToSet["showDevTools"] = showDevTools
        functionsToSet["closeDevTools"] = closeDevTools
        functionsToSet["callJavascriptFunction"] = callJavascriptFunction
        functionsToSet["evaluateJavaScript"] = evaluateJavaScript
        functionsToSet["shutDown"] = shutDown
        functionsToSet["injectScript"] = injectScript
        functionsToSet["focus"] = focusWebView
        functionsToSet["print"] = print
        functionsToSet["capture"] = capture

        var arr: Array<String> = []
        for key in functionsToSet.keys {
            arr.append(key)
        }
        return arr
    }

    private func sendEvent(name: String, value: String) {
        do {
            try context.dispatchStatusEventAsync(code: value, level: name)
        } catch {
        }
    }

#if os(iOS)
#else

    /*func createPopupWindow(url: URLRequest) {
        popupWindow = NSWindow(contentRect: NSMakeRect(0, 0, CGFloat(_popupDimensions.0), CGFloat(_popupDimensions.1)),
                styleMask: [.titled, .miniaturizable, .closable],
                backing: NSBackingStoreType.buffered, defer: false)

        popupWindow.center()
        popupWindow.isReleasedWhenClosed = false

       // let pd:PopupDelegate = PopupDelegate(popupVC:popupVC)

        popupWindow.delegate = self
        
        popupVC = PopupVC(request: url, width: _popupDimensions.0, height: _popupDimensions.1)
        popupWindow.contentView!.addSubview(popupVC!.view)
        popupWindow.makeKeyAndOrderFront(nil)
    }*/

    /*
    func windowWillClose(_ notification: Notification) {
        //this clears the popup window and it's webview

        trace("popup closed")
        trace("what was the url")

        popupVC.view.removeFromSuperview()
        popupVC = nil


        //TODO send event to as3 to say popup has closed

        //_popupWindow = nil
    }
    */

#endif



    // this handles target=_blank links by opening them in the same view
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            switch _popupBehaviour {
            case .block:
                break
            case .newWindow:
#if os(iOS)
                trace("Cannot open popup in new window on iOS. Opening in same window.")
                webView.load(navigationAction.request)

#else
                _popup.createPopupWindow(url: navigationAction.request)
                //createPopupWindow(url: navigationAction.request)
#endif
                break
            case .sameWindow:
                webView.load(navigationAction.request)
                break
            }
        }
        return nil
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        var props: Dictionary<String, Any> = Dictionary()
        props["url"] = webView.url!.absoluteString
        props["errorCode"] = 0
        props["errorText"] = withError.localizedDescription
        let json = JSON(props)
        sendEvent(name: WebViewANE.ON_FAIL, value: json.description)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError: Error) {
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    }

    func isSupported(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        var isSupported: Bool = false
#if os(iOS)
        if #available(iOS 9.0, *) {
            isSupported = true
        }
#else
        if #available(OSX 10.10, *) {
            isSupported = true
        }
#endif
        return try! FREObject.newObject(bool: isSupported)
    }

    func allowsMagnification(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
        return try! FREObject.newObject(bool: false)
#else
        if let wv = myWebView {
            return try! FREObject.newObject(bool: wv.allowsMagnification)
        }
        return try! FREObject.newObject(bool: true)
#endif
    }

    func backForwardList(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
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

    func go(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        do {
            if let inFRE0 = argv[0] {
                let offset: Int = try inFRE0.getAsInt()
                if let wv = myWebView {
                    wv.go(to: wv.backForwardList.item(at: offset)!)
                }
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }
        return nil
    }

    func getMagnification(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
#else
        do {
            if let wv = myWebView {
                return try FREObject.newObject(double: Double(wv.magnification))
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }
#endif
        return try! FREObject.newObject(double: 1.0)
    }

    func setMagnification(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
#else
        do {
            if let inFRE0 = argv[0], let inFRE1 = argv[1] {
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
#endif
        return nil
    }

    func showDevTools(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }

    func closeDevTools(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }

    func shutDown(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }

    func addToStage(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            if let wv = myWebView {
                rootViewController.view.addSubview(wv)
            }
        }
#else
        if let view = NSApp.mainWindow?.contentView {
            view.addSubview(myWebView!)
            isAdded = true
            return nil
        } else {
            //allow for mainWindow not having been set yet on NSApp
            let allWindows = NSApp.windows
            if allWindows.count > 0 {
                let mWin = allWindows[0]
                let view: NSView = mWin.contentView!
                if let wv = myWebView {
                    view.addSubview(wv)
                    isAdded = true
                    return nil
                }
            }
        }
#endif
        return nil
    }

    func removeFromStage(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = myWebView {
            wv.removeFromSuperview()
            isAdded = false
        }
        return nil
    }

    func setPositionAndSize(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        do {
            if let inFRE0 = argv[0], let inFRE1 = argv[1], let inFRE2 = argv[2],
               let inFRE3 = argv[3] {

                _x = try inFRE0.getAsCGFloat()
                _y = try inFRE1.getAsCGFloat()
                _width = try inFRE2.getAsCGFloat()
                _height = try inFRE3.getAsCGFloat()

            }

        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }

        if let wv = myWebView {

#if os(iOS)
            let realY = _y
            var frame: CGRect = wv.frame
            frame.origin.x = _x
            frame.origin.y = realY
            frame.size.width = _width
            frame.size.height = _height
            wv.frame = frame

#else
            let realY = ((NSApp.mainWindow?.contentLayoutRect.height)! - _height) - _y;
            //TODO make this better, perform calc in ANE
            wv.setFrameOrigin(NSPoint.init(x: _x, y: realY))
            wv.setFrameSize(NSSize.init(width: _width, height: _height))
#endif

        }
        return nil

    }

    func load(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        do {
            if let inFRE0 = argv[0] {
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
        return nil
    }

    func loadHTMLString(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        do {
            if let inFRE0 = argv[0] {
                let html: String = try inFRE0.getAsString()
                if let wv = myWebView {
                    wv.loadHTMLString(html, baseURL: nil) //TODO
                }
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }
        return nil
    }

    func loadFileURL(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        do {
            if let inFRE0 = argv[0], let inFRE1 = argv[1] {
                let url: String = try inFRE0.getAsString()
                let myURL = URL(string: url)
                let allowingReadAccessTo: String = try inFRE1.getAsString()
                let accessURL = URL(string: allowingReadAccessTo)

                if let wv = myWebView {
#if os(iOS)
                    wv.loadFileURL(myURL!, allowingReadAccessTo: accessURL!)
#else
                    if #available(OSX 10.11, *) {
                        wv.loadFileURL(myURL!, allowingReadAccessTo: accessURL!)
                    } else {
                        // Fallback on earlier versions //TODO
                    }
#endif
                }
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }
        return nil
    }

    func onFullScreen(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
#else
        do {
            if let inFRE0 = argv[0] {
                let fullScreen: Bool = try inFRE0.getAsBool()
                let tmpIsAdded = isAdded
                for win in NSApp.windows {
                    if (fullScreen && win.canBecomeMain && win.className.contains("AIR_FullScreen")) {
                        win.makeMain()
                        if (WebViewANE.escListener == nil) {
                            WebViewANE.escListener = NSEvent.addLocalMonitorForEvents(matching: [.keyUp]) { (event: NSEvent) -> NSEvent? in
                                let theX = event.locationInWindow.x
                                let theY = event.locationInWindow.y
                                let realY = ((NSApp.mainWindow?.contentLayoutRect.height)! - self._height) - self._y
                                if (event.keyCode == 53 && theX > self._x && theX < (self._width - self._x)
                                        && theY > realY && theY < (realY + self._height)) {
                                    self.sendEvent(name: WebViewANE.ON_ESC_KEY, value: "")
                                }
                                return event
                            }
                        }
                        break
                    } else if (!fullScreen && win.canBecomeMain && win.className.contains("AIR_PlayerContent")) {
                        win.makeMain()
                        win.orderFront(nil)
                        break
                    }
                }

                if (tmpIsAdded) {
                    _ = removeFromStage(ctx: ctx, argc: argc, argv: argv)
                    _ = addToStage(ctx: ctx, argc: argc, argv: argv)
                }
            }

        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }
#endif
        return nil
    }

    func reload(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = myWebView {
            wv.reload()
        }
        return nil
    }

    func reloadFromOrigin(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = myWebView {
            wv.reloadFromOrigin()
        }
        return nil
    }

    func stopLoading(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = myWebView {
            wv.stopLoading()
        }
        return nil
    }

    func goBack(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = myWebView {
            wv.goBack()
        }
        return nil
    }

    func goForward(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = myWebView {
            wv.goForward()
        }
        return nil
    }

    func evaluateJavaScript(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = myWebView {
            do {
                if let inFRE0 = argv[0] {
                    let js = try inFRE0.getAsString()
                    if let inFRE1 = argv[1] {
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
            } catch {
            }
        }
        return nil
    }

    func callJavascriptFunction(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        _ = evaluateJavaScript(ctx: ctx, argc: argc, argv: argv)
        return nil
    }

    func injectScript(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        do {
            if let inFRE0: FREObject = argv[0] {
                let injectCode: String = try inFRE0.getAsString()
                let userScript = WKUserScript.init(source: injectCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                userController.addUserScript(userScript)
            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }
        return nil
    }

    func focusWebView(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }

    func print(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? { //TODO
        trace("print is Windows only at the moment");
        return nil
    }

    func capture(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? { //TODO
        trace("capture is Windows only at the moment");
        return nil
    }


    /*! @abstract Invoked when a script message is received from a webpage.
     @param userContentController The user content controller invoking the
     delegate method.
     @param message The script message received.
     */

#if os(iOS)

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody: NSDictionary = message.body as? NSDictionary {
            let json = JSON(messageBody)
            sendEvent(name: WebViewANE.JS_CALLBACK_EVENT, value: json.description)
        }
    }

#else

    @available(OSX 10.10, *)
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody: NSDictionary = message.body as? NSDictionary {
            let json = JSON(messageBody)
            sendEvent(name: WebViewANE.JS_CALLBACK_EVENT, value: json.description)
        }
    }

#endif

    func setBackgroundColor(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
        do {

            if let inFRE0 = argv[0], let inFRE1 = argv[1], let inFRE2 = argv[2],
               let inFRE3 = argv[3] {
                let r = try inFRE0.getAsCGFloat()
                let g = try inFRE1.getAsCGFloat()
                let b = try inFRE2.getAsCGFloat()
                let a = try inFRE3.getAsCGFloat()
                if a == 0.0 {
                    _bgColor = UIColor.clear
                } else {
                    _bgColor = UIColor.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
                }
            }

        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
            return nil
        } catch {
            return nil
        }
#else

#endif

        return nil

    }


    func initWebView(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        do {
            if let initialUrlFRE: FREObject = argv[0] {
                _initialUrl = try initialUrlFRE.getAsString()
            }

            if let inFRE1 = argv[1], let inFRE2 = argv[2], let inFRE3 = argv[3],
               let inFRE4 = argv[4] {
                _x = try inFRE1.getAsCGFloat()
                _y = try inFRE2.getAsCGFloat()
                _width = try inFRE3.getAsCGFloat()
                _height = try inFRE4.getAsCGFloat()
            }

        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
            return nil
        } catch {
            return nil
        }

        do {
            if let settingsFRE: FREObject = argv[5] {
                if let settingsWK = try settingsFRE.getProperty(name: "webkit") {
#if os(iOS)

                    if let allowsInlineMediaPlayback: Bool = try settingsWK.getProperty(name: "allowsInlineMediaPlayback")?.getAsBool() {
                        configuration.allowsInlineMediaPlayback = allowsInlineMediaPlayback
                    }
                    if let allowsPictureInPictureMediaPlayback: Bool = try settingsWK.getProperty(name: "allowsPictureInPictureMediaPlayback")?.getAsBool() {
                        configuration.allowsPictureInPictureMediaPlayback = allowsPictureInPictureMediaPlayback
                    }

                    if #available(iOS 10.0, *) {
                        if let ignoresViewportScaleLimits: Bool = try settingsWK.getProperty(name: "ignoresViewportScaleLimits")?.getAsBool() {
                            configuration.ignoresViewportScaleLimits = ignoresViewportScaleLimits
                        }
                    }

                    if let allowsAirPlayForMediaPlayback: Bool = try settingsWK.getProperty(name: "allowsAirPlayForMediaPlayback")?.getAsBool() {
                        configuration.allowsAirPlayForMediaPlayback = allowsAirPlayForMediaPlayback
                    }

#else
                    if let plugInsEnabled: Bool = try settingsWK.getProperty(name: "plugInsEnabled")?.getAsBool() {
                        configuration.preferences.plugInsEnabled = plugInsEnabled
                    }
                    if let javaEnabled: Bool = try settingsWK.getProperty(name: "javaEnabled")?.getAsBool() {
                        configuration.preferences.javaEnabled = javaEnabled
                    }
                    if #available(OSX 10.11, *) {
                        if let allowsAirPlayForMediaPlayback: Bool = try settingsWK.getProperty(name: "allowsAirPlayForMediaPlayback")?.getAsBool() {
                            configuration.allowsAirPlayForMediaPlayback = allowsAirPlayForMediaPlayback
                        }
                    }

#endif


                    if let javaScriptEnabled: Bool = try settingsWK.getProperty(name: "javaScriptEnabled")?.getAsBool() {
                        configuration.preferences.javaScriptEnabled = javaScriptEnabled
                    }
                    if let javaScriptCanOpenWindowsAutomatically: Bool =
                    try settingsWK.getProperty(name: "javaScriptCanOpenWindowsAutomatically")?.getAsBool() {
                        configuration.preferences.javaScriptCanOpenWindowsAutomatically = javaScriptCanOpenWindowsAutomatically
                    }

                    if let minimumFontSize: CGFloat = try settingsWK.getProperty(name: "minimumFontSize")?.getAsCGFloat() {
                        configuration.preferences.minimumFontSize = minimumFontSize
                    }

                }

                if let userAgent: String = try settingsFRE.getProperty(name: "userAgent")?.getAsString() {
                    _userAgent = userAgent
                }

#if os(iOS)
#else
                if let popupSettings: Dictionary<String, AnyObject> = try settingsFRE.getProperty(name: "popup")?.getAsDictionary() {
                    _popup = Popup()

                    if let behaviour = popupSettings["behaviour"] as? Int {
                        _popupBehaviour = WebViewANE.PopupBehaviour(rawValue: behaviour)!
                    }
                    if let dimensions = popupSettings["dimensions"] as? Dictionary<String, Int> {
                        if let w = dimensions["width"], let h = dimensions["height"] {
                            _popup.popupDimensions.0 = w
                            _popup.popupDimensions.1 = h
                        }

                    }
                }
#endif

            }
        } catch let e as FREError {
            e.printStackTrace(#file, #line, #column)
        } catch {
        }

        userController.add(self, name: "webViewANE")
        configuration.userContentController = userController

        var realY = _y
#if os(iOS)
#else

        let allWindows = NSApp.windows
        var mWin: NSWindow?
        if allWindows.count > 0 {
            if let win = NSApp.mainWindow {
                mWin = win
            } else {
                //allow for mainWindow not having been set yet on NSApp
                mWin = allWindows[0]
            }
        } else {
            trace("no window to attach to")
            return nil
        }

        realY = ((mWin?.contentLayoutRect.height)! - _height) - _y
#endif


        let myRect: CGRect = CGRect.init(x: _x, y: realY, width: _width, height: _height)
        myWebView = WKWebView(frame: myRect, configuration: configuration)

        if let wv = myWebView {
#if os(iOS)

            wv.backgroundColor = _bgColor

            if UIColor.clear == _bgColor {
                wv.isOpaque = false
                wv.scrollView.backgroundColor = UIColor.clear
            }

#endif

            wv.translatesAutoresizingMaskIntoConstraints = false
            wv.navigationDelegate = self
            wv.uiDelegate = self

#if os(iOS)

            if let userAgent = _userAgent {
                wv.customUserAgent = userAgent
            }
#else
            if #available(OSX 10.11, *) {
                if let userAgent = _userAgent {
                    wv.customUserAgent = userAgent
                }
            }
#endif

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

        return nil

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        var props: Dictionary<String, Any> = Dictionary()

        switch keyPath! {
        case "estimatedProgress":
            props["propName"] = "estimatedProgress"
            props["value"] = myWebView?.estimatedProgress
            break
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
            break
        case "title":
            if let val = myWebView?.title {
                if val != "" {
                    props["propName"] = "title"
                    props["value"] = val
                }
            }
            break
        case "canGoBack":
            props["propName"] = "canGoBack"
            props["value"] = myWebView?.canGoBack
            break
        case "canGoForward":
            props["propName"] = "canGoForward"
            props["value"] = myWebView?.canGoForward
            break
        case "loading":
            props["propName"] = "isLoading"
            props["value"] = myWebView?.isLoading
            break
        default:
            props["propName"] = keyPath
            props["value"] = nil
            break
        }

        let json = JSON(props)
        //trace(json.description)
        if ((props["propName"]) != nil) {
            sendEvent(name: WebViewANE.ON_PROPERTY_CHANGE, value: json.description)
        }
        return

    }

    func setFREContext(ctx: FREContext) {
        context = ctx
    }


}
