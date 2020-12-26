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
import FreSwift

extension SwiftController: FreSwiftMainController {
    
    // must have this function !!
    // Make sure these funcs match those in WebViewANE.m
    @objc public func getFunctions(prefix: String) -> [String] {
        functionsToSet["\(prefix)reload"] = reload
        functionsToSet["\(prefix)load"] = load
        functionsToSet["\(prefix)init"] = initController
        functionsToSet["\(prefix)clearCache"] = clearCache
        functionsToSet["\(prefix)isSupported"] = isSupported
        functionsToSet["\(prefix)setVisible"] = setVisible
        functionsToSet["\(prefix)loadHTMLString"] = loadHTMLString
        functionsToSet["\(prefix)loadFileURL"] = loadFileURL
        functionsToSet["\(prefix)clearRequestHeaders"] = clearRequestHeaders
        functionsToSet["\(prefix)onFullScreen"] = onFullScreen
        functionsToSet["\(prefix)reloadFromOrigin"] = reloadFromOrigin
        functionsToSet["\(prefix)stopLoading"] = stopLoading
        functionsToSet["\(prefix)backForwardList"] = backForwardList
        functionsToSet["\(prefix)go"] = go
        functionsToSet["\(prefix)goBack"] = goBack
        functionsToSet["\(prefix)goForward"] = goForward
        functionsToSet["\(prefix)allowsMagnification"] = allowsMagnification
        functionsToSet["\(prefix)zoomIn"] = zoomIn
        functionsToSet["\(prefix)zoomOut"] = zoomOut
        functionsToSet["\(prefix)setViewPort"] = setViewPort
        functionsToSet["\(prefix)showDevTools"] = showDevTools
        functionsToSet["\(prefix)closeDevTools"] = closeDevTools
        functionsToSet["\(prefix)callJavascriptFunction"] = callJavascriptFunction
        functionsToSet["\(prefix)evaluateJavaScript"] = evaluateJavaScript
        functionsToSet["\(prefix)injectScript"] = injectScript
        functionsToSet["\(prefix)focus"] = focusWebView
        functionsToSet["\(prefix)print"] = print
        functionsToSet["\(prefix)printToPdf"] = printToPdf
        functionsToSet["\(prefix)capture"] = capture
        functionsToSet["\(prefix)getCapturedBitmapData"] = getCapturedBitmapData
        functionsToSet["\(prefix)addTab"] = addTab
        functionsToSet["\(prefix)closeTab"] = closeTab
        functionsToSet["\(prefix)setCurrentTab"] = setCurrentTab
        functionsToSet["\(prefix)getCurrentTab"] = getCurrentTab
        functionsToSet["\(prefix)getTabDetails"] = getTabDetails
        functionsToSet["\(prefix)shutDown"] = shutDown
        functionsToSet["\(prefix)addEventListener"] = addEventListener
        functionsToSet["\(prefix)removeEventListener"] = removeEventListener
        functionsToSet["\(prefix)getOsVersion"] = getOsVersion
        functionsToSet["\(prefix)deleteCookies"] = deleteCookies
        
        var arr: [String] = []
        for key in functionsToSet.keys {
            arr.append(key)
        }
        
        return arr
    }
    
    @objc public func dispose() {
    }
    
    // Must have this function. It exposes the methods to our entry ObjC.
    @objc public func callSwiftFunction(name: String, ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if let fm = functionsToSet[name] {
            return fm(ctx, argc, argv)
        }
        return nil
    }
    
    @objc public func setFREContext(ctx: FREContext) {
        self.context = FreContextSwift.init(freContext: ctx)
        // Turn on FreSwift logging
        FreSwiftLogger.shared.context = context
    }
    
    @objc public func onLoad() {
    }
    
}
