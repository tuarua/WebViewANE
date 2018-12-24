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
    static var TAG = "WebViewANE"
    internal var context: FreContextSwift!
    convenience init(context: FreContextSwift, webView: WKWebView) {
        self.init()
        self.context = context
        if let ci = webView.backForwardList.currentItem,
            let freCurrentItem = FreObjectSwift(className: "com.tuarua.webview.BackForwardListItem") {
            freCurrentItem.url = ci.url.absoluteString
            freCurrentItem.title = ci.title
            freCurrentItem.initialURL = ci.initialURL.absoluteString
            self.rawValue?["currentItem"] = freCurrentItem.rawValue
        }

        var i: UInt = 0
        if let freBackList = FREArray(className: "com.tuarua.webview.BackForwardListItem",
                                                length: webView.backForwardList.backList.count,
                                                fixed: true) {
            for item in webView.backForwardList.backList {
                if let freItem = FreObjectSwift(className: "com.tuarua.webview.BackForwardListItem") {
                    freItem.url = item.url.absoluteString
                    freItem.title = item.title
                    freItem.initialURL = item.initialURL.absoluteString
                    freBackList[i] = freItem.rawValue
                    i += 1
                }
            }
            self.rawValue?["backList"] = freBackList.rawValue
        }

        i = 0

        if let freForwardList = FREArray(className: "com.tuarua.webview.BackForwardListItem",
                                                   length: webView.backForwardList.forwardList.count,
                                                   fixed: true) {
            for item in webView.backForwardList.forwardList {
                if let freItem = FreObjectSwift(className: "com.tuarua.webview.BackForwardListItem") {
                    freItem.url = item.url.absoluteString
                    freItem.title = item.title
                    freItem.initialURL = item.initialURL.absoluteString
                    freForwardList[i] = freItem.rawValue
                    i += 1
                }
                
            }
            self.rawValue?["forwardList"] = freForwardList.rawValue
        }
    }

    public init() {
        var freObject: FREObject? = nil
        if let freClass =  FREObject(className: "com.tuarua.webview.BackForwardList") {
            freObject = freClass
        }
        super.init(freObject)
    }
}
