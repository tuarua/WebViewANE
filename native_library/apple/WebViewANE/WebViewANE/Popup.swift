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
import WebKit

class Popup: NSObject, NSWindowDelegate {
    private var _popupWindow: NSWindow?
    private var _popupVC: PopupVC!

    public func createPopupWindow(url: URLRequest, configuration: WKWebViewConfiguration, frame: CGRect) -> WKWebView? {
        if let p = _popupWindow {
            p.close()
        }
        _popupWindow = NSWindow(contentRect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height),
                styleMask: [.titled, .miniaturizable, .closable],
                backing: .buffered, defer: false)

        if frame.minX == -1 || frame.minY == -1 {
            _popupWindow?.center()
        } else {
            _popupWindow?.setFrameOrigin(CGPoint(x: frame.minX, y: frame.minY))
        }
        
        _popupWindow?.isReleasedWhenClosed = false
        _popupWindow?.delegate = self
        _popupVC = PopupVC(request: url, position: frame, configuration: configuration)
        guard let contentView = _popupWindow?.contentView else { return nil }
        contentView.addSubview(_popupVC.view)
        _popupWindow?.makeKeyAndOrderFront(nil)
        return _popupVC.webView
    }

    func windowWillClose(_ notification: Notification) {
        // this clears the popup window and it's webview
        _popupVC.dispose()
        _popupVC.view.removeFromSuperview()
        _popupVC = nil
    }

}
