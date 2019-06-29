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

class WebViewVC: WKWebView, FreSwiftController {
    static var TAG = "WebViewANE"
    internal var context: FreContextSwift!
    var _settings: Settings!
    private var _capturedBitmapData: CGImage?
    public var capturedBitmapData: CGImage? {
        return _capturedBitmapData
    }
    
    private var _tab: Int = 0
    public var tab: Int {
        get {
            return _tab
        }
        set {
            _tab = newValue
        }
    }

    convenience init(context: FreContextSwift, frame: CGRect, settings: Settings, tab: Int) {
        self.init(frame: frame, configuration: settings.configuration)
        _settings = settings
        self.context = context
#if os(iOS)
        self.scrollView.bounces = settings.configuration.doesBounce
        self.scrollView.delegate = self
#endif
        _tab = tab
    }
    
#if os(OSX)
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        for menuItem in menu.items {
            menuItem.isHidden = !_settings.hasContextMenu
            if  menuItem.identifier?.rawValue == "WKMenuItemIdentifierDownloadImage" ||
                menuItem.identifier?.rawValue == "WKMenuItemIdentifierDownloadLinkedFile" {
                menuItem.isHidden = true
            }
        }
    }
#endif
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "canGoForward", options: .new, context: nil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func getCapturedBitmapData() -> CGImage? {
        return capturedBitmapData
    }
    
    public func capture() {
#if os(iOS)
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale )
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let ui = newImage,
            let ci = CIImage(image: ui) {
            let context = CIContext(options: nil)
            if let cg = context.createCGImage(ci, from: ci.extent) {
                _capturedBitmapData = cg.copy(colorSpace: CGColorSpaceCreateDeviceRGB())
            }
        }
        self.dispatchEvent(name: WebViewEvent.ON_CAPTURE_COMPLETE, value: "")
#else
        if #available(OSX 10.13, *) {
            let config = WKSnapshotConfiguration()
            takeSnapshot(with: config, completionHandler: { (result: NSImage?, _: Error?) -> Void in
                if let snapshot = result {
                    self._capturedBitmapData = snapshot.cgImage(forProposedRect: nil, context: nil, hints: nil)
                }
                self.dispatchEvent(name: WebViewEvent.ON_CAPTURE_COMPLETE, value: "")
            }) 
        } else {
            warning("capture is macOS 10.13+ only")
        }
#endif
    }

    func load(request: URLRequest) {
        self.load(request)
    }

    func load(html: String, baseRequest: URLRequest?) {
        self.loadHTMLString(html, baseURL: baseRequest?.url)
    }

    func load(fileUrl: URL, allowingReadAccessTo: URL) {
#if os(iOS)
        self.loadFileURL(fileUrl, allowingReadAccessTo: allowingReadAccessTo)
#else
        if #available(OSX 10.11, *) {
            self.loadFileURL(fileUrl, allowingReadAccessTo: allowingReadAccessTo)
        } else {
           warning("loadFileURL macOS 10.11+ only")
        }
#endif
    }

    func evaluateJavaScript(js: String) {
        self.evaluateJavaScript(js, completionHandler: nil)
    }

    func evaluateJavaScript(js: String, callback: String) {
        self.evaluateJavaScript(js, completionHandler: { (result: Any?, error: Error?) -> Void in
            var props = [String: Any]()
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
            self.dispatchEvent(name: WebViewEvent.AS_CALLBACK_EVENT, value: JSON(props).description)
        })
    }

    func setPositionAndSize(viewPort: CGRect) {
#if os(iOS)
        let realY = viewPort.origin.y
        var frame: CGRect = self.frame
        frame.origin.x = viewPort.origin.x
        frame.origin.y = realY
        frame.size.width = viewPort.size.width
        frame.size.height = viewPort.size.height
        self.frame = frame
#else
        guard let height = NSApp.mainWindow?.contentLayoutRect.height else { return }
        let realY = height - viewPort.size.height - viewPort.origin.y
        self.setFrameOrigin(NSPoint(x: viewPort.origin.x, y: realY))
        self.setFrameSize(NSSize(width: viewPort.size.width, height: viewPort.size.height))
#endif
    }

    public func switchTabTo() {
        var props = [String: Any]()
        var json: JSON
        if let val = self.url?.absoluteString {
            if val != "" {
                props = Dictionary()
                props["propName"] = "url"
                props["value"] = val
                props["tab"] = _tab
                json = JSON(props)
                dispatchEvent(name: WebViewEvent.ON_PROPERTY_CHANGE, value: json.description)
            }
        }

        if let val = self.title {
            if val != "" {
                props = Dictionary()
                props["propName"] = "title"
                props["value"] = val
                props["tab"] = _tab
                json = JSON(props)
                dispatchEvent(name: WebViewEvent.ON_PROPERTY_CHANGE, value: json.description)
            }
        }

        props["propName"] = "canGoBack"
        props["value"] = self.canGoBack
        props["tab"] = _tab
        json = JSON(props)
        dispatchEvent(name: WebViewEvent.ON_PROPERTY_CHANGE, value: json.description)

        props["propName"] = "canGoForward"
        props["value"] = self.canGoForward
        props["tab"] = _tab
        json = JSON(props)
        dispatchEvent(name: WebViewEvent.ON_PROPERTY_CHANGE, value: json.description)

        props["propName"] = "isLoading"
        props["value"] = self.isLoading
        props["tab"] = _tab
        json = JSON(props)
        dispatchEvent(name: WebViewEvent.ON_PROPERTY_CHANGE, value: json.description)
        
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        var props = [String: Any]()

        switch keyPath! {
        case "estimatedProgress":
            props["propName"] = "estimatedProgress"
            props["value"] = self.estimatedProgress
        case "URL":
            if let val = self.url?.absoluteString {
                if val != "" {
                    props["propName"] = "url"
                    props["value"] = val
                } else {
                    return
                }
            } else {
                return
            }
        case "title":
            if let val = self.title {
                if val != "" {
                    props["propName"] = "title"
                    props["value"] = val
                }
            }
        case "canGoBack":
            props["propName"] = "canGoBack"
            props["value"] = self.canGoBack
        case "canGoForward":
            props["propName"] = "canGoForward"
            props["value"] = self.canGoForward
        case "loading":
            props["propName"] = "isLoading"
            props["value"] = self.isLoading
        default:
            props["propName"] = keyPath
            props["value"] = nil
        }

        props["tab"] = _tab
        if props["propName"] != nil {
            dispatchEvent(name: WebViewEvent.ON_PROPERTY_CHANGE, value: JSON(props).description)
        }
        return
    }

    func dispose() {
        self.removeObserver(self, forKeyPath: "loading")
        self.removeObserver(self, forKeyPath: "estimatedProgress")
        self.removeObserver(self, forKeyPath: "title")
        self.removeObserver(self, forKeyPath: "URL")
        self.removeObserver(self, forKeyPath: "canGoBack")
        self.removeObserver(self, forKeyPath: "canGoForward")
    }

#if os(OSX)
    override var isFlipped: Bool {
        return true
    }
#endif

}
