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
import FreSwift
#if os(OSX)
import Cocoa
#endif

public class SwiftController: FreSwiftController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    private var context: FreContextSwift!
    private func trace(_ value: Any...){
        freTrace(ctx: context, value: value)
    }
    
    private var _currentWebView: WebViewVC?
    private var _currentTab: Int = 0
    private var _tabList: NSMutableArray = NSMutableArray.init()
    private static var escListener: Any?
    private static let zoomIncrement:CGFloat = CGFloat.init(0.1)
    private var _initialUrl: String = ""
    private var _viewPort: CGRect = CGRect.init(x: 0, y: 0, width: 800, height: 600)
    
    public enum PopupBehaviour: Int {
        case block = 0
        case newWindow
        case sameWindow
    }

    private var _popupBehaviour: PopupBehaviour = PopupBehaviour.newWindow;
#if os(iOS)
    private var _bgColor = UIColor.white
#else
    private var _popup: Popup!
#endif
    private var _isAdded: Bool = false
    private var _settings: Settings!
    private var _userController: WKUserContentController = WKUserContentController()

    // must have this function !!
    // Make sure these funcs match those in WebViewANE.m
    @objc public func getFunctions(prefix: String) -> Array<String> {
        
        functionsToSet["\(prefix)reload"] = reload
        functionsToSet["\(prefix)load"] = load
        functionsToSet["\(prefix)init"] = initWebView
        functionsToSet["\(prefix)clearCache"] = clearCache
        functionsToSet["\(prefix)isSupported"] = isSupported
        functionsToSet["\(prefix)addToStage"] = addToStage
        functionsToSet["\(prefix)removeFromStage"] = removeFromStage
        functionsToSet["\(prefix)loadHTMLString"] = loadHTMLString
        functionsToSet["\(prefix)loadFileURL"] = loadFileURL
        functionsToSet["\(prefix)onFullScreen"] = onFullScreen
        functionsToSet["\(prefix)reloadFromOrigin"] = reloadFromOrigin
        functionsToSet["\(prefix)stopLoading"] = stopLoading
        functionsToSet["\(prefix)backForwardList"] = backForwardList
        functionsToSet["\(prefix)go"] = go
        functionsToSet["\(prefix)goBack"] = goBack
        functionsToSet["\(prefix)goForward"] = goForward
        functionsToSet["\(prefix)allowsMagnification"] = allowsMagnification
        functionsToSet["\(prefix)zoomIn"] = zoomIn
        functionsToSet["\(prefix)zoomOut"] = zoomOut
        functionsToSet["\(prefix)setPositionAndSize"] = setPositionAndSize
        functionsToSet["\(prefix)showDevTools"] = showDevTools
        functionsToSet["\(prefix)closeDevTools"] = closeDevTools
        functionsToSet["\(prefix)callJavascriptFunction"] = callJavascriptFunction
        functionsToSet["\(prefix)evaluateJavaScript"] = evaluateJavaScript
        functionsToSet["\(prefix)injectScript"] = injectScript
        functionsToSet["\(prefix)focus"] = focusWebView
        functionsToSet["\(prefix)print"] = print
        functionsToSet["\(prefix)capture"] = capture
        functionsToSet["\(prefix)addTab"] = addTab
        functionsToSet["\(prefix)closeTab"] = closeTab
        functionsToSet["\(prefix)setCurrentTab"] = setCurrentTab
        functionsToSet["\(prefix)getCurrentTab"] = getCurrentTab
        functionsToSet["\(prefix)getTabDetails"] = getTabDetails
        functionsToSet["\(prefix)shutDown"] = shutDown

        var arr: Array<String> = []
        for key in functionsToSet.keys {
            arr.append(key)
        }
        
        return arr
    }

    // this handles target=_blank links by opening them in the same view
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
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
                _popup.createPopupWindow(url: navigationAction.request, configuration: _settings.configuration)
#endif
                break
            case .sameWindow:
                webView.load(navigationAction.request)
                break
            }
        }
        return nil
    }

    
    fileprivate func isWhiteListBlocked(url:String) -> Bool {
        guard let list = _settings.urlWhiteList,
            list.count > 0
            else {
                return false
        }
        for item in list {
            if url.range(of: item as! String) != nil {
                return false
            }
        }
        return true
    }
    
    fileprivate func isBlackListBlocked(url:String) -> Bool {
        guard let list = _settings.urlBlackList,
            list.count > 0
            else {
                return false
        }
        
        for item in list {
            if url.range(of: item as! String) != nil {
                return true
            }
        }
        
        return false
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let newUrl = navigationAction.request.url?.absoluteString.lowercased()
            else {
                decisionHandler(.allow)
                return
        }
        
        if isWhiteListBlocked(url: newUrl) || isBlackListBlocked(url: newUrl) {
            var props: Dictionary<String, Any> = Dictionary()
            props["url"] = newUrl
            props["tab"] = 0

            if let wv = webView as? WebViewVC {
                for vc in _tabList {
                    if let theVC = vc as? WebViewVC {
                        if theVC.isEqual(wv) {
                            props["tab"] = theVC.tab
                            break
                        }
                    }
                }
            }
            
            let json = JSON(props)
            sendEvent(ctx: context, name: Constants.ON_URL_BLOCKED, value: json.description)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }

    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        var props: Dictionary<String, Any> = Dictionary()
        props["url"] = webView.url!.absoluteString
        props["errorCode"] = 0
        props["errorText"] = withError.localizedDescription
        let json = JSON(props)
        sendEvent(ctx: context, name: Constants.ON_FAIL, value: json.description)
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
            ret = try FreObjectSwift.init(bool: isSupported).rawValue
        } catch {
        }
        return ret
    }

    func allowsMagnification(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        var ret: FREObject? = nil
        do {
#if os(iOS)
            ret = try FreObjectSwift.init(bool: false).rawValue
#else
            if let wv = _currentWebView {
                ret = try FreObjectSwift.init(bool: wv.allowsMagnification).rawValue
            }
#endif
        } catch {
        }
        return ret
    }

    func backForwardList(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard let wv = _currentWebView
          else {
            traceError(ctx: context, message: "no webview", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        let bfList = BackForwardList.init(ctx: context, webView: wv)
        if let rv = bfList.rawValue {
            return rv
        }
        return nil

    }

    func go(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let inFRE0 = argv[0],
              let i = FreObjectSwift.init(freObject: inFRE0).value as? Int
          else {
            traceError(ctx: context, message: "go - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        if let item = wv.backForwardList.item(at: i) {
            wv.go(to: item)
        }
        return nil
    }
    
    func zoomIn(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        #if os(OSX)
        guard let wv = _currentWebView
            else {
                traceError(ctx: context, message: "zoomIn - no webview", line: #line, column: #column, file: #file, freError: nil)
                return nil
        }
        
        wv.setMagnification(CGFloat.init(wv.magnification + SwiftController.zoomIncrement), centeredAt: CGPoint.zero)
        #endif
        return nil
    }

    func zoomOut(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        #if os(OSX)
        guard let wv = _currentWebView
            else {
                traceError(ctx: context, message: "zoomIn - no webview", line: #line, column: #column, file: #file, freError: nil)
                return nil
        }
        
        wv.setMagnification(CGFloat.init(wv.magnification - SwiftController.zoomIncrement), centeredAt: CGPoint.zero)
        #endif
        return nil
    }

    func showDevTools(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        #if os(OSX)
            guard let wv = _currentWebView
                else {
                    traceError(ctx: context, message: "zoomIn - no webview", line: #line, column: #column, file: #file, freError: nil)
                    return nil
            }
        wv.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        #endif
        return nil
    }

    func closeDevTools(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        #if os(OSX)
            guard let wv = _currentWebView
                else {
                    traceError(ctx: context, message: "zoomIn - no webview", line: #line, column: #column, file: #file, freError: nil)
                    return nil
            }
            wv.configuration.preferences.setValue(false, forKey: "developerExtrasEnabled")
        #endif
        return nil
    }

    func addToStage(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard let wv = _currentWebView else {
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
        guard let wv = _currentWebView else {
            return nil
        }
        wv.removeFromSuperview()
        _isAdded = false
        return nil
    }

    func setPositionAndSize(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let inFRE0 = argv[0],
              let viewPortFre = FreRectangleSwift.init(freObject: inFRE0).value as? CGRect
          else {
            traceError(ctx: context, message: "setPositionAndSize - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        _viewPort = viewPortFre
        wv.setPositionAndSize(viewPort: _viewPort)
        return nil
    }

    func load(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let inFRE0 = argv[0],
              let url: String = FreObjectSwift(freObject: inFRE0).value as? String,
              !url.isEmpty else {
            traceError(ctx: context, message: "load - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        wv.load(url: url)
        return nil
    }

    func loadHTMLString(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let inFRE0 = argv[0],
              let html: String = FreObjectSwift(freObject: inFRE0).value as? String
          else {
            traceError(ctx: context, message: "loadHTMLString - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        wv.load(html: html)
        return nil
    }

    func loadFileURL(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let inFRE0 = argv[0],
              let inFRE1 = argv[1],
              let url: String = FreObjectSwift(freObject: inFRE0).value as? String,
              let allowingReadAccessTo: String = FreObjectSwift(freObject: inFRE1).value as? String
          else {
            traceError(ctx: context, message: "loadFileURL - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        wv.load(fileUrl: url, allowingReadAccessTo: allowingReadAccessTo)
        return nil
    }

    func onFullScreen(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
#else
        guard argc > 0, let inFRE0 = argv[0] else {
            traceError(ctx: context, message: "onFullScreen - incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        let fullScreen: Bool = FreObjectSwift.init(freObject: inFRE0).value as! Bool

        let tmpIsAdded = _isAdded
        for win in NSApp.windows {
            if (fullScreen && win.canBecomeMain && win.className.contains("AIR_FullScreen")) {
                win.makeMain()
                if (SwiftController.escListener == nil) {
                    SwiftController.escListener = NSEvent.addLocalMonitorForEvents(matching: [.keyUp]) { (event: NSEvent) -> NSEvent? in
                        let theX = event.locationInWindow.x
                        let theY = event.locationInWindow.y
                        let realY = ((NSApp.mainWindow?.contentLayoutRect.height)! - self._viewPort.size.height) - self._viewPort.origin.y
                        if (event.keyCode == 53 && theX > self._viewPort.origin.x && theX < (self._viewPort.size.width - self._viewPort.origin.x)
                          && theY > realY && theY < (realY + self._viewPort.size.height)) {
                            sendEvent(ctx: self.context, name: Constants.ON_ESC_KEY, value: "")
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
        if let wv = _currentWebView {
            wv.reload()
        }
        return nil
    }

    func reloadFromOrigin(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = _currentWebView {
            wv.reloadFromOrigin()
        }
        return nil
    }

    func stopLoading(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = _currentWebView {
            wv.stopLoading()
        }
        return nil
    }

    func goBack(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = _currentWebView {
            wv.goBack()
        }
        return nil
    }

    func goForward(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let wv = _currentWebView {
            wv.goForward()
        }
        return nil
    }

    func evaluateJavaScript(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let inFRE0 = argv[0],
              let js: String = FreObjectSwift(freObject: inFRE0).value as? String
          else {
            traceError(ctx: context, message: "evaluateJavaScript - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        if let inFRE1 = argv[1] {
            let callbackFre = FreObjectSwift.init(freObject: inFRE1)
            if FreObjectTypeSwift.string == callbackFre.getType(), let callback: String = callbackFre.value as? String {
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
              let injectCode: String = FreObjectSwift(freObject: inFRE0).value as? String
          else {
            traceError(ctx: context, message: "injectScript - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
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
        trace("print is Windows only at the moment")
        return nil
    }

    func capture(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? { //TODO - when 10.13 comes out
        trace("capture is Windows only at the moment")
        return nil
    }
    
    func shutDown(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }
    
    
    func clearCache(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        if #available(OSX 10.11, *) {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: NSDate(timeIntervalSince1970: 0) as Date, completionHandler: {})
            
        }
#else
        if #available(iOS 9.0, *) {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: NSDate(timeIntervalSince1970: 0) as Date, completionHandler: {})
            
        }
#endif
        return nil
    }

    func addTab(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        guard argc > 0,
              let wv = _currentWebView
          else {
            traceError(ctx: context, message: "addTab - no webview", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
    

        if let initialUrlFRE: FREObject = argv[0],
            let initialUrl = FreObjectSwift.init(freObject: initialUrlFRE).value as? String {
            _initialUrl = initialUrl
        } else {
            _initialUrl = ""
        }
        
        _currentTab = _tabList.count;

        _currentWebView = createNewBrowser(frame: CGRect.init(x: wv.frame.origin.x, y: wv.frame.origin.y, width: _viewPort.size.width, height: _viewPort.size.height), tab: _tabList.count)

        _ = removeFromStage(ctx: ctx, argc: argc, argv: argv)
        _ = addToStage(ctx: ctx, argc: argc, argv: argv)

#endif
        return nil
    }

    func closeTab(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        guard argc > 0,
              let cwv = _currentWebView,
              let inFRE0 = argv[0],
              let index: Int = FreObjectSwift(freObject: inFRE0).value as? Int,
              index > -1,
              index < (_tabList.count)
          else {
            traceError(ctx: context, message: "closeTab - no webview or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        let doRefresh = (_currentTab >= index)
        if _currentTab >= index {
            _currentTab = _currentTab - 1
        }
        if _tabList.count == 2 {
            _currentTab = 0
        }
        if _currentTab < 0 {
            _currentTab = 0
        }


        var wvtc: WebViewVC? = _tabList.object(at: index) as? WebViewVC
        if let wvToClose = wvtc {
            _tabList.removeObject(at: index)
            wvToClose.removeFromSuperview()
            wvToClose.dispose()
        }
        wvtc = nil

        let currentFrame = cwv.frame
        _currentWebView = _tabList[_currentTab] as? WebViewVC;

        var cnt = 0
        for vc in _tabList {
            if let theVC = vc as? WebViewVC {
                theVC.tab = cnt
                theVC.isHidden = !(theVC.tab == _currentTab)
            }
            cnt = cnt + 1
        }

        if (!doRefresh) {
            return nil
        }

        guard let wv = _currentWebView else {
            return nil
        }
        wv.frame = currentFrame
        wv.switchTabTo()
        _ = removeFromStage(ctx: ctx, argc: argc, argv: argv)
        _ = addToStage(ctx: ctx, argc: argc, argv: argv)

#endif
        return nil
    }


    func setCurrentTab(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        guard argc > 0,
              let cwv = _currentWebView,
              let inFRE0 = argv[0],
              let index: Int = FreObjectSwift(freObject: inFRE0).value as? Int,
              index > -1,
              index < (_tabList.count),
              index != _currentTab
          else {
            traceError(ctx: context, message: "setCurrentTab - no webview or current is already index or incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }

        for vc in _tabList {
            if let theVC = vc as? WebViewVC {
                theVC.isHidden = !(theVC.tab == index)
            }
        }
        let currentFrame = cwv.frame
        _currentTab = index;
        _currentWebView = _tabList[_currentTab] as? WebViewVC;


        guard let wv = _currentWebView else {
            return nil
        }
        wv.frame = currentFrame
        wv.switchTabTo()
        _ = removeFromStage(ctx: ctx, argc: argc, argv: argv)
        _ = addToStage(ctx: ctx, argc: argc, argv: argv)
#endif
        return nil
    }

    func getTabDetails(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        var ret: FREObject? = nil
        do {
            let airArray: FreArraySwift = try FreArraySwift.init(className: "Vector.<com.tuarua.webview.TabDetails>")
            ret = airArray.rawValue
            var cnt = 0
            for vc in _tabList {
                if let theVC = vc as? WebViewVC {
                    let currentTabFre = try FreObjectSwift.init(className: "com.tuarua.webview.TabDetails", args: theVC.tab, theVC.url!.absoluteString, theVC.title!, theVC.isLoading, theVC.canGoBack, theVC.canGoForward, theVC.estimatedProgress)
                    try airArray.setObjectAt(index: UInt(cnt), object: currentTabFre)
                    cnt = cnt + 1
                }
            }
        } catch {
        }
        return ret
    }


    func getCurrentTab(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        var ret: FREObject? = nil
        do {
            ret = try FreObjectSwift.init(int: _currentTab).rawValue
        } catch {
        }
        return ret
    }


#if os(iOS)

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody: NSDictionary = message.body as? NSDictionary {
            let json = JSON(messageBody)
            sendEvent(ctx: context, name: Constants.JS_CALLBACK_EVENT, value: json.description)
        }
    }

#else

    @available(OSX 10.10, *)
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody: NSDictionary = message.body as? NSDictionary {
            let json = JSON(messageBody)
            sendEvent(ctx: context, name: Constants.JS_CALLBACK_EVENT, value: json.description)
        }
    }

#endif


    fileprivate func createNewBrowser(frame: CGRect, tab: Int) -> WebViewVC {
        let wv = WebViewVC(ctx: context, frame: frame, configuration: _settings.configuration, tab: tab)

        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.navigationDelegate = self
        wv.uiDelegate = self

#if os(iOS)
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

        _tabList.add(wv)
        return wv
    }

    func initWebView(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let inFRE1 = argv[1],
              let inFRE4 = argv[4],
              let inFRE5 = argv[5],
              let viewPortFre = FreRectangleSwift.init(freObject: inFRE1).value as? CGRect
          else {
            traceError(ctx: context, message: "initWebView - incorrect arguments", line: #line, column: #column, file: #file, freError: nil)
            return nil
        }
        if let initialUrlFRE: FREObject = argv[0],
           let initialUrl = FreObjectSwift.init(freObject: initialUrlFRE).value as? String {
            _initialUrl = initialUrl
        }

        _viewPort = viewPortFre
        var realY = _viewPort.origin.y
#if os(iOS)
        do {
            _bgColor = try FreSwiftHelper.toUIColor(freObject: inFRE4, alpha: inFRE5)
        } catch {
        }
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
            trace("Cannot find AIR window to attach webView to. Ensure you init the ANE AFTER your main Sprite is initialised. " +
                "Please see https://forum.starling-framework.org/topic/webviewane-for-osx/page/7?replies=201#post-105524 for more details");
            return nil
        }

        realY = ((mWin?.contentLayoutRect.height)! - _viewPort.size.height) - _viewPort.origin.y
#endif


        if let settingsFRE: FREObject = argv[2] {
            if let settingsDict = FreObjectSwift.init(freObject: settingsFRE).value as? Dictionary<String, AnyObject> {
                _settings = Settings.init(dictionary: settingsDict)

#if os(OSX)
                if let popupSettings = settingsDict["popup"] {
                    _popup = Popup()
                    if let behaviour = popupSettings["behaviour"] as? Int {
                        _popupBehaviour = SwiftController.PopupBehaviour(rawValue: behaviour)!
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

        _currentWebView = createNewBrowser(frame: CGRect.init(x: _viewPort.origin.x, y: realY, width: _viewPort.size.width, height: _viewPort.size.height), tab: 0)

        return nil
    }

    @objc public func setFREContext(ctx: FREContext) {
        context = FreContextSwift.init(freContext: ctx)
    }

}
