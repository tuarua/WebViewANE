//
//  Popup.swift
//  WebViewANE
//
//  Created by Eoin Landy on 05/05/2017.
//  Copyright (c) 2017 Tua Rua Ltd. All rights reserved.
//

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
