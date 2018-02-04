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
                var props: [String: Any] = Dictionary()
                props["url"] = ""
                if let url = navigationAction.request.url?.absoluteString {
                    props["url"] = url
                }
                props["tab"] = getCurrentTab(webView)
                let json = JSON(props)
                sendEvent(name: Constants.ON_POPUP_BLOCKED, value: json.description)
            case .newWindow:
                #if os(iOS)
                    warning("Cannot open popup in new window on iOS. Opening in same window.")
                    webView.load(navigationAction.request)
                #else
                    _popup.createPopupWindow(url: navigationAction.request, configuration: _settings.configuration)
                #endif
            case .sameWindow:
                webView.load(navigationAction.request)
            }
        }
        return nil
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let newUrl = navigationAction.request.url?.absoluteString.lowercased()
            else {
                decisionHandler(.allow)
                return
        }
        
        if isWhiteListBlocked(url: newUrl) || isBlackListBlocked(url: newUrl) {
            var props: [String: Any] = Dictionary()
            props["url"] = newUrl
            props["tab"] = getCurrentTab(webView)
            
            let json = JSON(props)
            sendEvent(name: Constants.ON_URL_BLOCKED, value: json.description)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
        
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError: Error) {
        var props: [String: Any] = Dictionary()
        props["url"] = webView.url!.absoluteString
        props["errorCode"] = 0
        props["errorText"] = withError.localizedDescription
        let json = JSON(props)
        sendEvent(name: Constants.ON_FAIL, value: json.description)
    }
}
