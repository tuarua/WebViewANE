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

class WebViewVC: WKWebView, FreSwiftController {
    var TAG: String? = "WebViewANE"
    internal var context: FreContextSwift!
    private var _tab: Int = 0
    public var tab: Int {
        get {
            return _tab
        }
        set {
            _tab = newValue
        }
    }

    convenience init(context: FreContextSwift, frame: CGRect, configuration: Configuration, tab: Int) {
        self.init(frame: frame, configuration: configuration)
        self.context = context

#if os(iOS)
        self.scrollView.bounces = configuration.doesBounce
#endif
        _tab = tab
    }

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

    func load(url: String) {
        let myURL = URL(string: url)
        let myRequest = URLRequest(url: myURL!)
        self.load(myRequest)
    }

    func load(html: String) {
        self.loadHTMLString(html, baseURL: nil) //TODO
    }

    func load(fileUrl: String, allowingReadAccessTo: String) {
        let myURL = URL(string: fileUrl)
        let accessURL = URL(string: allowingReadAccessTo)

#if os(iOS)
        self.loadFileURL(myURL!, allowingReadAccessTo: accessURL!)
#else
        if #available(OSX 10.11, *) {
            self.loadFileURL(myURL!, allowingReadAccessTo: accessURL!)
        } else {
            // Fallback on earlier versions //TODO
        }
#endif
    }

    func evaluateJavaScript(js: String) {
        self.evaluateJavaScript(js, completionHandler: nil)
    }

    func evaluateJavaScript(js: String, callback: String) {
        self.evaluateJavaScript(js, completionHandler: { (result: Any?, error: Error?) -> Void in
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
            self.sendEvent(name: Constants.AS_CALLBACK_EVENT, value: json.description)
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
        let realY = ((NSApp.mainWindow?.contentLayoutRect.height)! - viewPort.size.height) - viewPort.origin.y;

        self.setFrameOrigin(NSPoint.init(x: viewPort.origin.x, y: realY))
        self.setFrameSize(NSSize.init(width: viewPort.size.width, height: viewPort.size.height))
#endif
    }

    public func switchTabTo() {
        var props: Dictionary<String, Any> = Dictionary()
        var json: JSON
        if let val = self.url?.absoluteString {
            if val != "" {
                props = Dictionary()
                props["propName"] = "url"
                props["value"] = val
                props["tab"] = _tab
                json = JSON(props)
                sendEvent(name: Constants.ON_PROPERTY_CHANGE, value: json.description)
            }
        }

        if let val = self.title {
            if val != "" {
                props = Dictionary()
                props["propName"] = "title"
                props["value"] = val
                props["tab"] = _tab
                json = JSON(props)
                sendEvent(name: Constants.ON_PROPERTY_CHANGE, value: json.description)
            }
        }

        props["propName"] = "canGoBack"
        props["value"] = self.canGoBack
        props["tab"] = _tab
        json = JSON(props)
        sendEvent(name: Constants.ON_PROPERTY_CHANGE, value: json.description)

        props["propName"] = "canGoForward"
        props["value"] = self.canGoForward
        props["tab"] = _tab
        json = JSON(props)
        sendEvent(name: Constants.ON_PROPERTY_CHANGE, value: json.description)

        props["propName"] = "isLoading"
        props["value"] = self.isLoading
        props["tab"] = _tab
        json = JSON(props)
        sendEvent(name: Constants.ON_PROPERTY_CHANGE, value: json.description)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        var props: Dictionary<String, Any> = Dictionary()

        switch keyPath! {
        case "estimatedProgress":
            props["propName"] = "estimatedProgress"
            props["value"] = self.estimatedProgress
            break
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
            break
        case "title":
            if let val = self.title {
                if val != "" {
                    props["propName"] = "title"
                    props["value"] = val
                }
            }
            break
        case "canGoBack":
            props["propName"] = "canGoBack"
            props["value"] = self.canGoBack
            break
        case "canGoForward":
            props["propName"] = "canGoForward"
            props["value"] = self.canGoForward
            break
        case "loading":
            props["propName"] = "isLoading"
            props["value"] = self.isLoading
            break
        default:
            props["propName"] = keyPath
            props["value"] = nil
            break
        }

        props["tab"] = _tab
        let json = JSON(props)
        if ((props["propName"]) != nil) {
            sendEvent(name: Constants.ON_PROPERTY_CHANGE, value: json.description)
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
