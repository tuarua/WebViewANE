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

class BackForwardList: FreObjectSwift, FreSwiftController {
    internal var context: FreContextSwift!
    convenience init(context:FreContextSwift, webView: WKWebView) {
        self.init()
        self.context = context
        do {
            if let ci = webView.backForwardList.currentItem, let freCurrentItem = try? FreObjectSwift.init(className: "com.tuarua.webview.BackForwardListItem") {
                try freCurrentItem.setProperty(name: "url", prop: FreObjectSwift.init(string: ci.url.absoluteString))
                try freCurrentItem.setProperty(name: "title", prop: FreObjectSwift.init(string: ci.title!))
                try freCurrentItem.setProperty(name: "initialURL", prop: FreObjectSwift.init(string: ci.initialURL.absoluteString))
                try self.setProperty(name: "currentItem", prop: freCurrentItem)
            }

            var i = 0
            if let freBackList = try? FreArraySwift.init(className: "Vector.<com.tuarua.webview.BackForwardListItem>") {
                for item in webView.backForwardList.backList {
                    if let freItem = try? FreObjectSwift.init(className: "com.tuarua.webview.BackForwardListItem") {
                        try freItem.setProperty(name: "url", prop: FreObjectSwift.init(string: item.url.absoluteString))
                        try freItem.setProperty(name: "title", prop: FreObjectSwift.init(string: item.title!))
                        try freItem.setProperty(name: "initialURL", prop: FreObjectSwift.init(string: item.initialURL.absoluteString))
                        try freBackList.setObjectAt(index: UInt(i), object: freItem)
                        i = i + 1
                    }
                }
                try self.setProperty(name: "backList", array: freBackList)
            }

            i = 0

            if let freForwardList = try? FreArraySwift.init(className: "Vector.<com.tuarua.webview.BackForwardListItem>") {
                for item in webView.backForwardList.forwardList {
                    if let freItem = try? FreObjectSwift.init(className: "com.tuarua.webview.BackForwardListItem") {
                        try freItem.setProperty(name: "url", prop: FreObjectSwift.init(string: item.url.absoluteString))
                        try freItem.setProperty(name: "title", prop: FreObjectSwift.init(string: item.title!))
                        try freItem.setProperty(name: "initialURL", prop: FreObjectSwift.init(string: item.initialURL.absoluteString))
                        try freForwardList.setObjectAt(index: UInt(i), object: freItem)
                        i = i + 1
                    }
                }
                try self.setProperty(name: "forwardList", array: freForwardList)
            }

        } catch let e as FreError {
            traceError(message: "backForwardList error", line: #line, column: #column, file: #file, freError: e)
        } catch {
        }


    }

    public init() {
        var freObject: FREObject? = nil
        if let freClass = try? FreObjectSwift.init(className: "com.tuarua.webview.BackForwardList") {
            if let rv = freClass.rawValue {
                freObject = rv
            }
        }
        super.init(freObject: freObject)
    }
}
