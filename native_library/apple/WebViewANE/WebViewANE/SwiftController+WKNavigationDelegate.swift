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

extension SwiftController: WKNavigationDelegate {
  
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return completionHandler(.useCredential, nil) }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    
    // this handles target=_blank links by opening them in the same view
    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            switch _popupBehaviour {
            case .block:
                var props = [String: Any]()
                props["url"] = ""
                if let url = navigationAction.request.url?.absoluteString {
                    props["url"] = url
                }
                props["tab"] = getCurrentTab(webView)
                dispatchEvent(name: WebViewEvent.ON_POPUP_BLOCKED, value: JSON(props).description)
            case .newWindow, .replace:
                #if os(iOS)
                    warning("Cannot open popup in new window on iOS. Opening in same window.")
                    webView.load(navigationAction.request)
                #else
                _popup?.createPopupWindow(url: navigationAction.request, configuration: _settings.configuration)
                #endif
            case .sameWindow:
                webView.load(navigationAction.request)
            }
        }
        return nil
    }
    
#if os(OSX)
    fileprivate func saveDownload(url: URL, location: URL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        let task = session.downloadTask(with: request)
        downloadTaskSaveTos[task.taskIdentifier] = location
        task.resume()
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    
        if let url = navigationResponse.response.url,
            let suggestedFilename = navigationResponse.response.suggestedFilename,
            !navigationResponse.canShowMIMEType {
            
            if !_settings.enableDownloads {
                decisionHandler(.cancel)
                return
            }
            
            if let downloadPath = _settings.downloadPath {
                var location = URL(safe: downloadPath)
                location?.appendPathComponent(suggestedFilename)
                if let location = location {
                    saveDownload(url: url, location: location)
                }
            } else {
                let saveDialog = NSSavePanel()
                saveDialog.parent = NSApp.mainWindow
                saveDialog.canCreateDirectories = true
                saveDialog.nameFieldStringValue = suggestedFilename
                let result = saveDialog.runModal()
                switch result {
                case NSApplication.ModalResponse.OK :
                    if let location = saveDialog.url {
                        saveDownload(url: url, location: location)
                    }
                case NSApplication.ModalResponse.cancel:
                    dispatchEvent(name: WebViewEvent.ON_DOWNLOAD_CANCEL, value: url.absoluteString)
                default: break
                }
            }
            decisionHandler(.cancel)
        }
        decisionHandler(.allow)
    }
#endif
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url
            else {
                decisionHandler(.allow)
                return
        }
        let newUrl = url.absoluteString.lowercased()
        if isWhiteListBlocked(url: newUrl) || isBlackListBlocked(url: newUrl) {
            var props = [String: Any]()
            props["url"] = newUrl
            props["tab"] = getCurrentTab(webView)
            dispatchEvent(name: WebViewEvent.ON_URL_BLOCKED, value: JSON(props).description)
            decisionHandler(.cancel)
        } else {
            let userAction = (navigationAction.navigationType != .other)
            if userAction && _settings.persistRequestHeaders, let host = navigationAction.request.url?.host {
                var request = URLRequest(url: url)
                for header in _persistantRequestHeaders[host] ?? [] {
                    request.addValue(header.1, forHTTPHeaderField: header.0)
                }
                decisionHandler(.cancel)
                webView.load(request)
            }
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        var props = [String: Any]()
        props["url"] = webView.url!.absoluteString
        props["errorCode"] = 0
        props["errorText"] = withError.localizedDescription
        dispatchEvent(name: WebViewEvent.ON_FAIL, value: JSON(props).description)
    }
}
