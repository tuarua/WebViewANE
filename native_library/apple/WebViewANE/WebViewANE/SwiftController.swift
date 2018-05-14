// Copyright 2018 Tua Rua Ltd.
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
#if canImport(Cocoa)
import Cocoa
#endif
public class SwiftController: NSObject {
    public var TAG: String? = "WebViewANE"
    public var context: FreContextSwift!
    public var functionsToSet: FREFunctionMap = [:]
    private var _currentWebView: WebViewVC?
    private var _currentTab: Int = 0
    private var _tabList: NSMutableArray = NSMutableArray()
    private static var escListener: Any?
    private static var keyUpListener: Any?
    private static var keyDownListener: Any?
    private static let zoomIncrement: CGFloat = CGFloat(0.1)
    private var _initialUrl: String = ""
    private var _viewPort: CGRect = CGRect(x: 0.0, y: 0.0, width: 800.0, height: 600.0)
    private var _capturedCropTo: CGRect?
    internal var _popupBehaviour: PopupBehaviour = PopupBehaviour.newWindow
#if os(iOS)
    private var _bgColor = UIColor.white
#else
    internal var _popup: Popup?
#endif
    private var _isAdded: Bool = false
    internal var _settings: Settings!
    private var _userController: WKUserContentController = WKUserContentController()
    
    private func addKeyListener(type: String) {
#if os(OSX)
        let eventMask: NSEvent.EventTypeMask = type == "keyUp" ? .keyUp : .keyDown
        var listener: Any? = type == "keyUp" ? SwiftController.keyUpListener : SwiftController.keyDownListener
        if listener == nil {
            listener = NSEvent.addLocalMonitorForEvents(matching: [eventMask]) { (event: NSEvent) -> NSEvent? in
                var modifiers: String = ""
                switch event.modifierFlags.intersection(NSEvent.ModifierFlags.deviceIndependentFlagsMask) {
                case [.shift]:
                    modifiers = "shift"
                case [.control]:
                    modifiers = "control"
                case [.option]:
                    modifiers = "alt"
                case [.command]:
                    modifiers = "command"
                case [.control, .shift]:
                    modifiers = "control-shift"
                case [.option, .shift]:
                    modifiers = "option-shift"
                case [.command, .shift]:
                    modifiers = "command-shift"
                case [.control, .shift]:
                    modifiers = "control-shift"
                case [.control, .command]:
                    modifiers = "control-command"
                case [.option, .command]:
                    modifiers = "alt-command"
                case [.shift, .control, .option]:
                    modifiers = "shift-control-option"
                case [.shift, .control, .command]:
                    modifiers = "shift-control-command"
                case [.shift, .option, .command]:
                    modifiers = "shift-alt-command"
                case [.shift, .command, .option]:
                    modifiers = "shift-command-alt"
                default:
                    break
                }

                if let characters = event.charactersIgnoringModifiers {
                    let s = characters.uppercased().unicodeScalars
                    var keyValue: UInt32 = 0
                    switch event.keyCode {
                    case 51: //BACKSPACE
                        keyValue = 8
                    case 53: //ESC
                        keyValue = 27
                    case 123: //LEFT
                        keyValue = 37
                    case 124: //RIGHT
                        keyValue = 39
                    case 125: //DOWN
                        keyValue = 40
                    case 126: //UP
                        keyValue = 38
                    default:
                        keyValue = s[s.startIndex].value
                    }
                    var props: [String: Any] = Dictionary()
                    props["keyCode"] = keyValue
                    props["nativeKeyCode"] = event.keyCode
                    props["modifiers"] = modifiers
                    props["isSystemKey"] = false
                    self.sendEvent(name: event.type == .keyUp ? WebViewEvent.ON_KEY_UP : WebViewEvent.ON_KEY_DOWN,
                                   value: JSON(props).description)

                }

                return event
            }
        }
#endif
    }

    func addEventListener(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        guard argc > 0,
              let type = String(argv[0])
          else {
             return ArgCountError(message: "addEventListener").getError(#file, #line, #column)
        }
        if type == "keyUp" || type == "keyDown" {
            addKeyListener(type: type)
        }
#endif
        return nil
    }

    func removeEventListener(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        guard argc > 0,
              let type = String(argv[0])
          else {
            return ArgCountError(message: "removeEventListener").getError(#file, #line, #column)
        }

        let listener: Any? = type == "keyUp" ? SwiftController.keyUpListener : SwiftController.keyDownListener
        if let lstnr = listener {
            NSEvent.removeMonitor(lstnr)
        }
#endif
        return nil
    }

    func isSupported(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        var isSupported: Bool = false
        if #available(iOS 9.0, OSX 10.10, *) {
            isSupported = true
        }
        return isSupported.toFREObject()
    }

    func allowsMagnification(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
        return false.toFREObject()
#else
        return _currentWebView?.allowsMagnification.toFREObject()
#endif
    }

    func backForwardList(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard let wv = _currentWebView
          else {
            return ArgCountError(message: "backForwardList").getError(#file, #line, #column)
        }

        let bfList = BackForwardList.init(context: context, webView: wv)
        if let rv = bfList.rawValue {
            return rv
        }
        return nil

    }

    func go(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let i = Int(argv[0])
          else {
            return ArgCountError(message: "go").getError(#file, #line, #column)
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
                return ArgCountError(message: "zoomIn").getError(#file, #line, #column)
        }
        wv.setMagnification(CGFloat(wv.magnification + SwiftController.zoomIncrement), centeredAt: CGPoint.zero)
#endif
        return nil
    }

    func zoomOut(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        guard let wv = _currentWebView
            else {
                return ArgCountError(message: "zoomOut").getError(#file, #line, #column)
        }
        wv.setMagnification(CGFloat(wv.magnification - SwiftController.zoomIncrement), centeredAt: CGPoint.zero)
#endif
        return nil
    }

    func showDevTools(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        _currentWebView?.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
#endif
        return nil
    }

    func closeDevTools(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        _currentWebView?.configuration.preferences.setValue(false, forKey: "developerExtrasEnabled")
#endif
        return nil
    }

    func setVisible(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let visible = Bool(argv[0])
          else {
            return ArgCountError(message: "setVisible").getError(#file, #line, #column)
        }

        if !_isAdded {
            addToStage()
        }
        wv.isHidden = !visible
        return nil
    }

    private func addToStage() {
        guard let wv = _currentWebView else {
            return
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
    }

    private func removeFromStage() {
        guard let wv = _currentWebView else {
            return
        }
        wv.removeFromSuperview()
        _isAdded = false
    }

    func setViewPort(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let viewPortFre = CGRect(argv[0])
          else {
            return ArgCountError(message: "setViewPort").getError(#file, #line, #column)
        }

        _viewPort = viewPortFre
        wv.setPositionAndSize(viewPort: _viewPort)
        return nil
    }

    func load(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let url = String(argv[0]),
              !url.isEmpty else {
            return ArgCountError(message: "load").getError(#file, #line, #column)
        }
        wv.load(url: url)
        return nil
    }

    func loadHTMLString(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let html =  String(argv[0])
          else {
            return ArgCountError(message: "loadHTMLString").getError(#file, #line, #column)
        }
        wv.load(html: html)
        return nil
    }

    func loadFileURL(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let wv = _currentWebView,
            let urlStr = String(argv[0]),
            let url = URL(safe: urlStr),
            let allowingReadAccessToStr = String(argv[1]),
            let allowingReadAccessTo = URL(safe: allowingReadAccessToStr)
            else {
                return ArgCountError(message: "loadFileURL").getError(#file, #line, #column)
        }
        wv.load(fileUrl: url, allowingReadAccessTo: allowingReadAccessTo)
        return nil
    }

    func onFullScreen(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
#else
        guard argc > 0,
            let fullScreen = Bool(argv[0]) else {
            return ArgCountError(message: "onFullScreen").getError(#file, #line, #column)
        }

        let tmpIsAdded = _isAdded
        for win in NSApp.windows {
            if fullScreen && win.canBecomeMain && win.className.contains("AIR_FullScreen") {
                win.makeMain()
                if SwiftController.escListener == nil {
                    SwiftController.escListener = NSEvent.addLocalMonitorForEvents(
                    matching: [NSEvent.EventTypeMask.keyUp]) { (event: NSEvent) -> NSEvent? in
                        let theX = event.locationInWindow.x
                        let theY = event.locationInWindow.y
                        let realY = ((NSApp.mainWindow?.contentLayoutRect.height)!
                            - self._viewPort.size.height) - self._viewPort.origin.y
                        if event.keyCode == 53
                            && theX > self._viewPort.origin.x
                            && theX < (self._viewPort.size.width - self._viewPort.origin.x)
                            && theY > realY && theY < (realY + self._viewPort.size.height) {
                            self.sendEvent(name: WebViewEvent.ON_ESC_KEY, value: "")
                        }
                        return event
                    }
                }
                break
            } else if !fullScreen && win.canBecomeMain && win.className.contains("AIR_PlayerContent") {
                win.makeMain()
                win.orderFront(nil)
                break
            }
        }

        if tmpIsAdded {
            _ = removeFromStage()
            _ = addToStage()
        }

#endif
        return nil
    }

    func reload(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        _currentWebView?.reload()
        return nil
    }

    func reloadFromOrigin(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        _currentWebView?.reloadFromOrigin()
        return nil
    }

    func stopLoading(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        _currentWebView?.stopLoading()
        return nil
    }

    func goBack(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        _currentWebView?.goBack()
        return nil
    }

    func goForward(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        _currentWebView?.goForward()
        return nil
    }

    func evaluateJavaScript(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let wv = _currentWebView,
              let js = String(argv[0])
          else {
            return ArgCountError(message: "evaluateJavaScript").getError(#file, #line, #column)
        }
        
        if let callback = String(argv[1]) {
            wv.evaluateJavaScript(js: js, callback: callback)
            return nil
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
              let injectCode = String(argv[0])
          else {
            return ArgCountError(message: "injectScript").getError(#file, #line, #column)
        }

        let userScript = WKUserScript(source: injectCode, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        _userController.addUserScript(userScript)
        return nil
    }

    func focusWebView(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }

    func print(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        warning("print is Windows only.")
        return nil
    }
    
    func printToPdf(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        warning("printToPdf is Windows only.")
        return nil
    }
    
    func capture(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let wvc = _currentWebView else {
                return ArgCountError(message: "capture").getError(#file, #line, #column)
        }
        _capturedCropTo = scaleViewPort(rect: CGRect(argv[0]))
        wvc.capture()
        return nil
    }
    
    private func scaleViewPort(rect: CGRect?) -> CGRect {
        guard let rect = rect else { return CGRect.zero }
#if os(iOS)
        let multiplier = UIScreen.main.scale
#else
        let multiplier = CGFloat(1)
#endif
        
        return CGRect(x: rect.origin.x * multiplier,
                      y: rect.origin.y * multiplier,
                      width: rect.size.width * multiplier,
                      height: rect.size.height * multiplier)
    }
    
    func getCapturedBitmapData(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard let wvc = _currentWebView else {
                return ArgCountError(message: "getCapturedBitmapData").getError(#file, #line, #column)
        }
        guard let captured = wvc.capturedBitmapData else { return nil }
        let x = _capturedCropTo?.origin.x ?? 0
        let y = _capturedCropTo?.origin.y ?? 0
        let w = _capturedCropTo?.size.width ?? 0
        let h = _capturedCropTo?.size.height ?? 0
        do {
            if let freObject = try FREObject(className: "flash.display.BitmapData",
                                             args: captured.width, captured.height, false) {
                let asBitmapData = FreBitmapDataSwift(freObject: freObject)
                defer {
                    asBitmapData.releaseData()
                }
                do {
                    try asBitmapData.acquire()
                    try asBitmapData.setPixels(cgImage: captured)
                    asBitmapData.releaseData()
                    if w > 0 && h > 0 {
                        if let destBmd = try FREObject(className: "flash.display.BitmapData",
                                                       args: w, h, false) {
                            if let bmd = asBitmapData.rawValue,
                                let sourceRect = CGRect(x: x, y: y, width: w, height: h).toFREObject(),
                                let destPoint = CGPoint.zero.toFREObject() {
                                _ = try destBmd.call(method: "copyPixels", args: bmd, sourceRect, destPoint)
                                return destBmd
                            }
                        }
                    } else {
                        return asBitmapData.rawValue
                    }
                } catch let e as FreError {
                    return e.getError(#file, #line, #column)
                } catch {}
            }
        } catch let e as FreError {
            return e.getError(#file, #line, #column)
        } catch {
        }
        
        return FreBitmapDataSwift(cgImage: captured).rawValue
    }
    
    func shutDown(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        removeFromStage()
        _currentWebView = nil
        for vc in _tabList {
            var theVC = vc as? WebViewVC
            theVC?.isHidden = true
            theVC?.dispose()
            theVC = nil
        }
        return nil
    }

    func clearCache(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if #available(iOS 9.0, OSX 10.11, *) {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            if let websiteDataTypes = websiteDataTypes as? Set<String> {
                WKWebsiteDataStore.default().removeData(
                    ofTypes: websiteDataTypes,
                    modifiedSince: NSDate(timeIntervalSince1970: 0) as Date,
                    completionHandler: {})
            }
        }
        return nil
    }

    func addTab(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        guard argc > 0,
              let wv = _currentWebView
          else {
            return ArgCountError(message: "addTab").getError(#file, #line, #column)
        }

        if let initialUrl = String(argv[0]) {
            _initialUrl = initialUrl
        } else {
            _initialUrl = ""
        }

        _currentTab = _tabList.count

        _currentWebView = createNewBrowser(
          frame: CGRect(x: wv.frame.origin.x, y: wv.frame.origin.y,
                             width: _viewPort.size.width, height: _viewPort.size.height),
          tab: _tabList.count)

        _ = removeFromStage()
        _ = addToStage()

#endif
        return nil
    }

    func closeTab(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        guard argc > 0,
              let cwv = _currentWebView,
              let index = Int(argv[0]),
              index > -1,
              index < (_tabList.count)
          else {
            return ArgCountError(message: "closeTab").getError(#file, #line, #column)
        }

        let doRefresh = (_currentTab >= index)
        if _currentTab >= index {
            _currentTab -= 1
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
        _currentWebView = _tabList[_currentTab] as? WebViewVC

        var cnt = 0
        for vc in _tabList {
            if let theVC = vc as? WebViewVC {
                theVC.tab = cnt
                theVC.isHidden = !(theVC.tab == _currentTab)
            }
            cnt += 1
        }

        if !doRefresh {
            return nil
        }

        guard let wv = _currentWebView else {
            return nil
        }
        wv.frame = currentFrame
        wv.switchTabTo()
        _ = removeFromStage()
        _ = addToStage()

#endif
        return nil
    }

    func setCurrentTab(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(OSX)
        guard argc > 0,
              let cwv = _currentWebView,
              let index = Int(argv[0]),
              index > -1,
              index < (_tabList.count),
              index != _currentTab
          else {
            return ArgCountError(message: "setCurrentTab").getError(#file, #line, #column)
        }

        for vc in _tabList {
            if let theVC = vc as? WebViewVC {
                theVC.isHidden = !(theVC.tab == index)
            }
        }
        let currentFrame = cwv.frame
        _currentTab = index
        _currentWebView = _tabList[_currentTab] as? WebViewVC

        guard let wv = _currentWebView else {
            return nil
        }
        wv.frame = currentFrame
        wv.switchTabTo()
        _ = removeFromStage()
        _ = addToStage()
#endif
        return nil
    }

    func getTabDetails(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        var ret: FREObject? = nil
        do {
            let airArray: FREArray = try FREArray(className: "Vector.<com.tuarua.webview.TabDetails>")
            ret = airArray.rawValue
            var cnt = 0
            for vc in _tabList {
                if let theVC = vc as? WebViewVC {
                    if let currentTabFre = try FREObject(className: "com.tuarua.webview.TabDetails",
                                                              args: theVC.tab,
                                                              theVC.url!.absoluteString,
                                                              theVC.title!,
                                                              theVC.isLoading,
                                                              theVC.canGoBack,
                                                              theVC.canGoForward,
                                                              theVC.estimatedProgress) {
                        try airArray.set(index: UInt(cnt), value: currentTabFre)
                    }
                    cnt += 1
                }
            }
        } catch {
        }
        return ret
    }

    func getCurrentTab(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return _currentTab.toFREObject()
    }

    fileprivate func createNewBrowser(frame: CGRect, tab: Int) -> WebViewVC {
        let wv = WebViewVC(context: context, frame: frame, settings: _settings, tab: tab)

        wv.translatesAutoresizingMaskIntoConstraints = false
        wv.navigationDelegate = self
        wv.uiDelegate = self

#if os(iOS)
        wv.backgroundColor = _bgColor
        if UIColor.clear == _bgColor {
            wv.isOpaque = false
            wv.scrollView.backgroundColor = UIColor.clear
        }

        wv.customUserAgent = _settings.userAgent
#else
        if #available(OSX 10.11, *) {
            wv.customUserAgent = _settings.userAgent
        }
#endif

        if !_initialUrl.isEmpty {
            wv.load(url: _initialUrl)
        }

        _tabList.add(wv)
        return wv
    }

    func initController(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 4,
              let inFRE4 = argv[4],
              let viewPortFre = CGRect(argv[1])
          else {
            return ArgCountError(message: "initWebView").getError(#file, #line, #column)
        }
        if let initialUrl = String(argv[0]) {
            _initialUrl = initialUrl
        }

        _viewPort = viewPortFre
        var realY = _viewPort.origin.y
#if os(iOS)
        _bgColor = UIColor(freObjectARGB: inFRE4) ?? UIColor.white
        if _bgColor.cgColor.alpha == 0.0 {
            _bgColor = UIColor.clear
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
            return FreError(stackTrace: "", message: "Cannot find AIR window to attach webView to. Ensure you init "
                + "the ANE AFTER your main Sprite is initialised. Please see " +
              "https://forum.starling-framework.org/topic/webviewane-for-osx/page/7?replies=201#post-105524 " +
                "for more details", type: FreError.Code.ok).getError(#file, #line, #column)
        }

        realY = ((mWin?.contentLayoutRect.height)! - _viewPort.size.height) - _viewPort.origin.y
#endif
        _settings = Settings(argv[2])
#if os(OSX)
        _popup = Popup()
        _popup?.popupDimensions = _settings.popupDimensions
        _popupBehaviour = _settings.popupBehaviour
#endif

        _userController.add(self, name: "webViewANE")
        _settings.configuration.userContentController = _userController

        _currentWebView = createNewBrowser(frame:
            CGRect(x: _viewPort.origin.x,
                   y: realY,
                   width: _viewPort.size.width,
                   height: _viewPort.size.height),
                                           tab: 0)

        return nil
    }

    func getOsVersion(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        let os = ProcessInfo().operatingSystemVersion
        return [os.majorVersion, os.minorVersion, os.patchVersion].toFREObject()
    }
    
    internal func getCurrentTab(_ webView: WKWebView?) -> Int {
        if let wv = webView as? WebViewVC {
            for vc in _tabList {
                if let theVC = vc as? WebViewVC {
                    if theVC.isEqual(wv) {
                        return theVC.tab
                    }
                }
            }
        }
        return 0
    }

    internal func isWhiteListBlocked(url: String) -> Bool {
        guard _settings.urlWhiteList.count > 0
          else {
            return false
        }
        let urlClean = url.lowercased()
        for item in _settings.urlWhiteList {
            if urlClean.range(of: item.lowercased()) != nil {
                return false
            }
        }
        return true
    }

    internal func isBlackListBlocked(url: String) -> Bool {
        guard _settings.urlBlackList.count > 0
          else {
            return false
        }
        let urlClean = url.lowercased()
        for item in _settings.urlBlackList {
            if urlClean.range(of: item.lowercased()) != nil {
                return true
            }
        }

        return false
    }

}
