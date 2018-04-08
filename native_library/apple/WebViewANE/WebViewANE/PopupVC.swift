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

import Cocoa
import Foundation
import WebKit

class PopupVC: NSViewController, WKUIDelegate, WKNavigationDelegate {
    private var _webView: WKWebView?
    private var _configuration: WKWebViewConfiguration!
    private var _request: URLRequest!
    private var _width: Int!
    private var _height: Int!

    convenience init(request: URLRequest, width: Int, height: Int, configuration: WKWebViewConfiguration) {
        self.init()
        self._request = request
        self._width = width
        self._height = height
        self._configuration = configuration

        _webView = WKWebView(frame: self.view.frame, configuration: _configuration)
        if let wv = _webView {
            wv.translatesAutoresizingMaskIntoConstraints = true
            wv.navigationDelegate = self
            wv.uiDelegate = self
            wv.addObserver(self, forKeyPath: "title", options: .new, context: nil)
            wv.load(_request)
            self.view.addSubview(wv)
        }
    }

    func dispose() {
        if let wv = _webView {
            wv.removeObserver(self, forKeyPath: "title")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func loadView() {
        let myRect: NSRect = NSRect.init(x: 0, y: 0, width: _width, height: _height)
        self.view = NSView.init(frame: myRect)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let wv = _webView else {
            return
        }

        switch keyPath! {
        case "title":
            if let val = wv.title {
                if val != "" {
                    self.view.window?.title = val
                }
            }
        default:
            break
        }
        return
    }
    
    @available(OSX 10.12, *)
    public func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters,
                        initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = true
        openPanel.begin(completionHandler: {(result) in
            if result.rawValue == NSFileHandlingPanelOKButton {
                completionHandler(openPanel.urls)
            } else {
                completionHandler([])
            }
        })
    }

}
