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

open class Configuration: WKWebViewConfiguration {
    
    private var _bounces: Bool = true
    public var doesBounce: Bool {
        return _bounces
    }
    
    private var _useZoomGestures = true
    public var useZoomGestures: Bool {
        return _useZoomGestures
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    convenience init(_ freObject: FREObject?) {
        guard let rv = freObject,
            let allowsInlineMediaPlayback = Bool(rv["allowsInlineMediaPlayback"]),
            let plugInsEnabled = Bool(rv["plugInsEnabled"]),
            let javaEnabled = Bool(rv["javaEnabled"]),
            let javaScriptEnabled = Bool(rv["javaScriptEnabled"]),
            let javaScriptCanOpenWindowsAutomatically = Bool(rv["javaScriptCanOpenWindowsAutomatically"]),
            let allowsPictureInPictureMediaPlayback = Bool(rv["allowsPictureInPictureMediaPlayback"]),
            let ignoresViewportScaleLimits = Bool(rv["ignoresViewportScaleLimits"]),
            let allowsAirPlayForMediaPlayback = Bool(rv["allowsAirPlayForMediaPlayback"]),
            let bounces = Bool(rv["bounces"]),
            let useZoomGestures = Bool(rv["useZoomGestures"]),
            let minimumFontSize = CGFloat(rv["minimumFontSize"])
            else {
                self.init()
                return
        }
        self.init()
        self.preferences.javaScriptCanOpenWindowsAutomatically = javaScriptCanOpenWindowsAutomatically
        self.preferences.javaScriptEnabled = javaScriptEnabled
        self.preferences.minimumFontSize = minimumFontSize
        
        if let freCustom = rv["custom"] {
            let custom = FREArray(freCustom)
            for index in 0..<custom.length {
                if let argFre = custom[index],
                    let key = String(argFre["key"]),
                    let val = argFre["value"],
                    let v = try? FreObjectSwift(any: val).value {
                    self.preferences.setValue(v, forKey: key)
                }
            }
        }
        
#if os(iOS)
        self.allowsInlineMediaPlayback = allowsInlineMediaPlayback
        self.allowsPictureInPictureMediaPlayback = allowsPictureInPictureMediaPlayback
        self.allowsAirPlayForMediaPlayback = allowsAirPlayForMediaPlayback
        self._bounces = bounces
        self._useZoomGestures = useZoomGestures
        if #available(iOS 10.0, *) {
            self.ignoresViewportScaleLimits = ignoresViewportScaleLimits
        }
#else
        self.preferences.plugInsEnabled = plugInsEnabled
        self.preferences.javaEnabled = javaEnabled
        if #available(OSX 10.11, *) {
            self.allowsAirPlayForMediaPlayback = allowsInlineMediaPlayback
        }
#endif
    }
}
