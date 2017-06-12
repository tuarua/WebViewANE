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

import Cocoa

class Popup: NSObject, NSWindowDelegate {
    private var popupWindow: NSWindow!
    private var popupVC: PopupVC!
    public var popupDimensions: (Int, Int) = (800, 600)

    public func createPopupWindow(url: URLRequest) {
        popupWindow = NSWindow(contentRect: NSMakeRect(0, 0, CGFloat(popupDimensions.0), CGFloat(popupDimensions.1)),
                styleMask: [.titled, .miniaturizable, .closable],
                backing: NSBackingStoreType.buffered, defer: false)

        popupWindow.center()
        popupWindow.isReleasedWhenClosed = false
        popupWindow.delegate = self
        popupVC = PopupVC(request: url, width: popupDimensions.0, height: popupDimensions.1)
        popupWindow.contentView!.addSubview(popupVC!.view)
        popupWindow.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        //this clears the popup window and it's webview
        popupVC.view.removeFromSuperview()
        popupVC = nil
    }

}
