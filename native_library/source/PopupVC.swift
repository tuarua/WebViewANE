//
//  PopupVC.swift
//  WebViewANE
//
//  Created by Eoin Landy on 04/05/2017.
//  Copyright © 2017 Tua Rua Ltd. All rights reserved.
//

import Cocoa
import Foundation
import WebKit

class PopupVC: NSViewController, WKUIDelegate, WKNavigationDelegate {
    private var webView: WKWebView?
    private var configuration: WKWebViewConfiguration = WKWebViewConfiguration()
    private var _request: URLRequest!
    private var _width: Int!
    private var _height: Int!

    convenience init(request: URLRequest, width: Int, height: Int) {
        self.init()
        self._request = request
        self._width = width
        self._height = height

        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        if let wv = webView {
            wv.translatesAutoresizingMaskIntoConstraints = true
            wv.navigationDelegate = self
            wv.uiDelegate = self
            wv.load(_request)
            self.view.addSubview(wv)
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

}
