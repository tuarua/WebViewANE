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

class BackForwardList: FreObjectSwift, FreSwiftController {
    var TAG: String? = "WebViewANE"
    internal var context: FreContextSwift!
    convenience init(context: FreContextSwift, webView: WKWebView) {
        self.init()
        self.context = context
        do {
            if let ci = webView.backForwardList.currentItem,
                let freCurrentItem = try FREObject.init(className: "com.tuarua.webview.BackForwardListItem") {
                try freCurrentItem.setProp(name: "url", value: ci.url.absoluteString)
                try freCurrentItem.setProp(name: "title", value: ci.title)
                try freCurrentItem.setProp(name: "initialURL", value: ci.initialURL.absoluteString)
                try self.rawValue?.setProp(name: "currentItem", value: freCurrentItem)
            }

            var i = 0
            if let freBackList = try? FREArray.init(className: "Vector.<com.tuarua.webview.BackForwardListItem>") {
                for item in webView.backForwardList.backList {
                    if let freItem = try FREObject.init(className: "com.tuarua.webview.BackForwardListItem") {
                        
                        try freItem.setProp(name: "url", value: item.url.absoluteString)
                        try freItem.setProp(name: "title", value: item.title)
                        try freItem.setProp(name: "initialURL", value: item.initialURL.absoluteString)
                        try freBackList.set(index: UInt(i), value: freItem)
                        i += 1
                        
                    }
                }
                try self.rawValue?.setProp(name: "backList", value: freBackList.rawValue)
            }

            i = 0

            if let freForwardList = try? FREArray.init(className: "Vector.<com.tuarua.webview.BackForwardListItem>") {
                for item in webView.backForwardList.forwardList {
                    if let freItem = try FREObject.init(className: "com.tuarua.webview.BackForwardListItem") {
                        try freItem.setProp(name: "url", value: FreObjectSwift.init(string: item.url.absoluteString))
                        try freItem.setProp(name: "title", value: item.title)
                        try freItem.setProp(name: "initialURL", value: item.initialURL.absoluteString)
                        try freForwardList.set(index: UInt(i), value: freItem)
                        i += 1
                    }
                    
                }
                try self.rawValue?.setProp(name: "forwardList", value: freForwardList.rawValue)
            }

        } catch let e as FreError {
            trace(e.message)
        } catch {
        }

    }

    public init() {
        var freObject: FREObject? = nil
        if let freClass = try? FREObject.init(className: "com.tuarua.webview.BackForwardList") {
            freObject = freClass
        }
        super.init(freObject: freObject)
    }
}
