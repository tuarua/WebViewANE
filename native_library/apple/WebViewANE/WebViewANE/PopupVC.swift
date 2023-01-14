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

class PopupVC: NSViewController, WKUIDelegate, WKNavigationDelegate,
URLSessionTaskDelegate, URLSessionDelegate, URLSessionDownloadDelegate {
    var webView: WKWebView?
    private var request: URLRequest!
    private var position: CGRect!
    private var downloadTaskSaveTos = [Int: URL]()

    convenience init(request: URLRequest, position: CGRect, configuration: WKWebViewConfiguration) {
        self.init()
        self.request = request
        self.position = position

        webView = WKWebView(frame: self.view.frame, configuration: configuration)
        if let wv = webView {
            wv.translatesAutoresizingMaskIntoConstraints = true
            wv.navigationDelegate = self
            wv.uiDelegate = self
            wv.addObserver(self, forKeyPath: "title", options: .new, context: nil)
            wv.load(request)
            self.view.addSubview(wv)
        }
    }

    func dispose() {
        if let wv = webView {
            wv.removeObserver(self, forKeyPath: "title")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        self.view = NSView(frame: CGRect(x: 0, y: 0, width: position.width, height: position.height))
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let wv = webView else {
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
            if result == NSApplication.ModalResponse.OK {
                completionHandler(openPanel.urls)
            } else {
                completionHandler([])
            }
        })
    }
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didFinishDownloadingTo location: URL) {
        guard let destinationURL = downloadTaskSaveTos[downloadTask.taskIdentifier] else { return }
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch {}
        
        downloadTaskSaveTos[downloadTask.taskIdentifier] = nil
    }
    
    public func urlSession(_ session: URLSession,
                           downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64,
                           totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        var props = [String: Any]()
        props["id"] = downloadTask.taskIdentifier
        props["url"] = downloadTask.originalRequest?.url?.absoluteString
        props["speed"] = 0
        props["percent"] = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)) * 100
        props["bytesLoaded"] = Double(totalBytesWritten)
        props["bytesTotal"] = Double(totalBytesExpectedToWrite)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url
            else {
                decisionHandler(.allow)
                return
        }
        let userAction = (navigationAction.navigationType != .other)
        if userAction && UrlRequestHeaderManager.shared.persistRequestHeaders,
            let host = navigationAction.request.url?.host,
            UrlRequestHeaderManager.shared.persistentRequestHeaders.index(forKey: host) != nil {
            var request = URLRequest(url: url)
            for header in UrlRequestHeaderManager.shared.persistentRequestHeaders[host] ?? [] {
                request.addValue(header.1, forHTTPHeaderField: header.0)
            }
            decisionHandler(.cancel)
            webView.load(request)
        }
        decisionHandler(.allow)
    }

}
