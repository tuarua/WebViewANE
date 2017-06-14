// Copyright 2017 Tua Rua Ltd.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 
//  Additional Terms
//  No part, or derivative of this Air Native Extensions's code is permitted 
//  to be sold as the basis of a commercially packaged Air Native Extension which 
//  undertakes the same purpose as this software. That is, a WebView for Windows, 
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.

import Foundation
import WebKit

#if os(iOS)

import FRESwift

#else

import Cocoa

#endif

@objc class WebViewANE: FRESwiftController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    private var _webView: WebViewVC?
    static var escListener: Any?
    private var _initialUrl: String = ""
    private var _viewPort: CGRect = CGRect.init(x: 0, y: 0, width: 800, height: 600)

    public enum PopupBehaviour: Int {
        case block = 0
        case newWindow
        case sameWindow
    }

    private var _popupBehaviour: PopupBehaviour = PopupBehaviour.newWindow;
#if os(iOS)
#else
    private var _popup: Popup!
#endif
    private var _isAdded: Bool = false
    private var _settings: Settings!
    private var _userController: WKUserContentController = WKUserContentController()

    // must have this function !!
    // Must set const numFunctions in WebViewANE.m to the length of this Array
    func getFunctions() -> Array<String> {

        functionsToSet["reload"] = reload
        functionsToSet["load"] = load
        functionsToSet["init"] = initWebView
        functionsToSet["isSupported"] = isSupported
        functionsToSet["addToStage"] = addToStage
        functionsToSet["removeFromStage"] = removeFromStage
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
#endif
                break
            case .sameWindow:
                webView.load(navigationAction.request)
                break
            }
        }
        return nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlWhiteList = _settings.urlWhiteList,
              urlWhiteList.count > 0,
              let newUrl = navigationAction.request.url?.absoluteString.lowercased()
          else {
            decisionHandler(.allow)
            return
        }

        for url in urlWhiteList {
            if newUrl.range(of: url as! String) != nil {
                decisionHandler(.allow)
                return
            }
        }
        sendEvent(name: Constants.ON_URL_BLOCKED, value: newUrl)
        decisionHandler(.cancel)

    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        var props: Dictionary<String, Any> = Dictionary()
        props["url"] = webView.url!.absoluteString
        props["errorCode"] = 0
        props["errorText"] = withError.localizedDescription
        let json = JSON(props)
        sendEvent(name: Constants.ON_FAIL, value: json.description)
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

        var ret: FREObject? = nil
        do {
            ret = try FREObjectSwift.init(bool: isSupported).rawValue
        } catch {
        }
        return ret
    }

    func allowsMagnification(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        var ret: FREObject? = nil
        do {
#if os(iOS)
            ret = try FREObjectSwift.init(bool: false).rawValue
#else
            if let wv = _webView {
                ret = try FREObjectSwift.init(bool: wv.allowsMagnification).rawValue
            }
#endif
        } catch {
        }
        return ret
    }

    func backForwardList(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard let wv = _webView
          else {
            traceError(message: "no webview", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        let bfList = BackForwardList.init(webView: wv)
        if let rv = bfList.rawValue {
            return rv
        }
        return nil

    }

    func go(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _webView,
              let inFRE0 = argv[0],
              let i = FREObjectSwift.init(freObject: inFRE0).value as? Int
          else {
            traceError(message: "go - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        if let item = wv.backForwardList.item(at: i) {
            wv.go(to: item)
        }
        return nil
    }

    func getMagnification(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _webView
          else {
            traceError(message: "getMagnification - no webview", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        var ret: FREObject? = nil
#if os(iOS)
#else
        do {
            ret = try FREObjectSwift.init(double: Double(wv.magnification)).rawValue
        } catch {
        }
#endif
        return ret
    }

    func setMagnification(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
#else
        guard argc > 0,
              let wv = _webView,
              let inFRE0 = argv[0],
              let inFRE1 = argv[1]
          else {
            traceError(message: "setMagnification - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        let magFre = FREObjectSwift.init(freObject: inFRE0)
        var magnification = CGFloat.init(1)
        if FREObjectTypeSwift.int == magFre.getType() {
            magnification = CGFloat.init(magFre.value as! Int)
        }
        if FREObjectTypeSwift.number == magFre.getType() {
            magnification = CGFloat.init(magFre.value as! Double)
        }

        var centeredAt = CGPoint.init()
        if let ca = FREPointSwift.init(freObject: inFRE1).value as? CGPoint {
            centeredAt = ca
        }

        wv.setMagnification(magnification, centeredAt: centeredAt)
#endif
        return nil
    }

    func showDevTools(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }

    func closeDevTools(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }

    func addToStage(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard let wv = _webView else {
            return nil
        }
#if os(iOS)
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.view.addSubview(wv)
            _isAdded = true
        }
#else
        if let view = NSApp.mainWindow?.contentView {
            view.addSubview(wv)
            _isAdded = true
        } else {
            //allow for mainWindow not having been set yet on NSApp
            let allWindows = NSApp.windows
            if allWindows.count > 0 {
                let mWin = allWindows[0]
                if let view: NSView = mWin.contentView {
                    view.addSubview(wv)
                    _isAdded = true
                }
            }
        }
#endif
        return nil
    }

    func removeFromStage(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard let wv = _webView else {
            return nil
        }
        wv.removeFromSuperview()
        _isAdded = false
        return nil
    }

    func setPositionAndSize(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _webView,
              let inFRE0 = argv[0],
              let viewPortFre = FRERectangleSwift.init(freObject: inFRE0).value as? CGRect
          else {
            traceError(message: "setPositionAndSize - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        _viewPort = viewPortFre
        wv.setPositionAndSize(viewPort: _viewPort)
        return nil
    }

    func load(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _webView,
              let inFRE0 = argv[0],
              let url: String = FREObjectSwift(freObject: inFRE0).value as? String,
              !url.isEmpty else {
            traceError(message: "load - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        wv.load(url: url)
        return nil
    }

    func loadHTMLString(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _webView,
              let inFRE0 = argv[0],
              let html: String = FREObjectSwift(freObject: inFRE0).value as? String
          else {
            traceError(message: "loadHTMLString - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        wv.load(html: html)
        return nil
    }

    func loadFileURL(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _webView,
              let inFRE0 = argv[0],
              let inFRE1 = argv[1],
              let url: String = FREObjectSwift(freObject: inFRE0).value as? String,
              let allowingReadAccessTo: String = FREObjectSwift(freObject: inFRE1).value as? String
          else {
            traceError(message: "loadFileURL - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        wv.load(fileUrl: url, allowingReadAccessTo: allowingReadAccessTo)
        return nil
    }

    func onFullScreen(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
#else
        guard argc > 0, let inFRE0 = argv[0] else {
            traceError(message: "onFullScreen - incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        let fullScreen: Bool = FREObjectSwift.init(freObject: inFRE0).value as! Bool

        let tmpIsAdded = _isAdded
        for win in NSApp.windows {
            if (fullScreen && win.canBecomeMain && win.className.contains("AIR_FullScreen")) {
                win.makeMain()
                if (WebViewANE.escListener == nil) {
                    WebViewANE.escListener = NSEvent.addLocalMonitorForEvents(matching: [.keyUp]) { (event: NSEvent) -> NSEvent? in
                        let theX = event.locationInWindow.x
                        let theY = event.locationInWindow.y
                        let realY = ((NSApp.mainWindow?.contentLayoutRect.height)! - self._viewPort.size.height) - self._viewPort.origin.y
                        if (event.keyCode == 53 && theX > self._viewPort.origin.x && theX < (self._viewPort.size.width - self._viewPort.origin.x)
                          && theY > realY && theY < (realY + self._viewPort.size.height)) {
                            sendEvent(name: Constants.ON_ESC_KEY, value: "")
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

#endif
        return nil
    }

    func reload(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = _webView {
            wv.reload()
        }
        return nil
    }

    func reloadFromOrigin(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = _webView {
            wv.reloadFromOrigin()
        }
        return nil
    }

    func stopLoading(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = _webView {
            wv.stopLoading()
        }
        return nil
    }

    func goBack(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = _webView {
            wv.goBack()
        }
        return nil
    }

    func goForward(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = _webView {
            wv.goForward()
        }
        return nil
    }

    func evaluateJavaScript(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _webView,
              let inFRE0 = argv[0],
              let js: String = FREObjectSwift(freObject: inFRE0).value as? String
          else {
            traceError(message: "evaluateJavaScript - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        if let inFRE1 = argv[1] {
            let callbackFre = FREObjectSwift.init(freObject: inFRE1)
            if FREObjectTypeSwift.string == callbackFre.getType(), let callback: String = callbackFre.value as? String {
                wv.evaluateJavaScript(js: js, callback: callback)
                return nil
            }
        }
        wv.evaluateJavaScript(js: js)
        return nil
    }

    func callJavascriptFunction(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        _ = evaluateJavaScript(ctx: ctx, argc: argc, argv: argv)
        return nil
    }

    func injectScript(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let inFRE0 = argv[0],
              let injectCode: String = FREObjectSwift(freObject: inFRE0).value as? String
          else {
            traceError(message: "injectScript - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        let userScript = WKUserScript.init(source: injectCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        _userController.addUserScript(userScript)
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

#if os(iOS)

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody: NSDictionary = message.body as? NSDictionary {
            let json = JSON(messageBody)
            sendEvent(name: Constants.JS_CALLBACK_EVENT, value: json.description)
        }
    }

#else

    @available(OSX 10.10, *)
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody: NSDictionary = message.body as? NSDictionary {
            let json = JSON(messageBody)
            sendEvent(name: Constants.JS_CALLBACK_EVENT, value: json.description)
        }
    }

#endif

    func initWebView(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let inFRE1 = argv[1],
              let inFRE4 = argv[4],
            let inFRE5 = argv[5],
              let viewPortFre = FRERectangleSwift.init(freObject: inFRE1).value as? CGRect
          else {
            traceError(message: "initWebView - incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        if let initialUrlFRE: FREObject = argv[0],
            let initialUrl = FREObjectSwift.init(freObject: initialUrlFRE).value as? String {
                _initialUrl = initialUrl
        }
        
        _viewPort = viewPortFre

        if let settingsFRE: FREObject = argv[2] {
            if let settingsDict = FREObjectSwift.init(freObject: settingsFRE).value as? Dictionary<String, AnyObject> {
                _settings = Settings.init(dictionary: settingsDict)

#if os(iOS)
#else
                if let popupSettings = settingsDict["popup"] {
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
        }

        _userController.add(self, name: "webViewANE")
        _settings.configuration.userContentController = _userController

        
        var realY = _viewPort.origin.y
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

        realY = ((mWin?.contentLayoutRect.height)! - _viewPort.size.height) - _viewPort.origin.y
#endif
        let myRect: CGRect = CGRect.init(x: _viewPort.origin.x, y: realY, width: _viewPort.size.width, height: _viewPort.size.height)

        
        
        _webView = WebViewVC(frame: myRect, configuration: _settings.configuration)

        guard let wv = _webView else {
            traceError(message: "initWebView - no webview", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.navigationDelegate = self
        wv.uiDelegate = self

#if os(iOS)

        var _bgColor = UIColor.white
        do {
            _bgColor = try FRESwiftHelper.toUIColor(freObject: inFRE4, alpha: inFRE5)
        } catch {
        }

        wv.backgroundColor = _bgColor
        if UIColor.clear == _bgColor {
            wv.isOpaque = false
            wv.scrollView.backgroundColor = UIColor.clear
        }

        if let userAgent = _settings.userAgent {
            wv.customUserAgent = userAgent
        }
#else
        if #available(OSX 10.11, *) {
            if let userAgent = _settings.userAgent {
                wv.customUserAgent = userAgent
            }
        }
#endif

        if !_initialUrl.isEmpty {
            wv.load(url: _initialUrl)
        }

        return nil
    }

    func setFREContext(ctx: FREContext) {
        context = FREContextSwift.init(freContext: ctx)
    }

}
