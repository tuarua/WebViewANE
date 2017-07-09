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

import Foundation
import WebKit
#if os(iOS)
    import FRESwift
#else
    import Cocoa
#endif

open class Configuration: WKWebViewConfiguration {
    
    private var _bounces: Bool = true
    
    public var doesBounce: Bool {
        get {
            return _bounces
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        if let settingsWK = dictionary["webkit"] {
#if os(iOS)
            if let allowsInlineMediaPlayback: Bool = settingsWK["allowsInlineMediaPlayback"] as? Bool {
                self.allowsInlineMediaPlayback = allowsInlineMediaPlayback
            }
            if let allowsPictureInPictureMediaPlayback: Bool = settingsWK["allowsPictureInPictureMediaPlayback"] as? Bool {
                self.allowsPictureInPictureMediaPlayback = allowsPictureInPictureMediaPlayback
            }
    
            if #available(iOS 10.0, *) {
                if let ignoresViewportScaleLimits: Bool = settingsWK["ignoresViewportScaleLimits"] as? Bool {
                    self.ignoresViewportScaleLimits = ignoresViewportScaleLimits
                }
            }

            if let allowsAirPlayForMediaPlayback: Bool = settingsWK["allowsAirPlayForMediaPlayback"] as? Bool {
                self.allowsAirPlayForMediaPlayback = allowsAirPlayForMediaPlayback
            }
    
            if let bounces: Bool = settingsWK["bounces"] as? Bool {
                self._bounces = bounces
            }

#else
            if let plugInsEnabled: Bool = settingsWK["plugInsEnabled"] as? Bool {
                self.preferences.plugInsEnabled = plugInsEnabled
            }
            if let javaEnabled: Bool = settingsWK["javaEnabled"] as? Bool {
                self.preferences.javaEnabled = javaEnabled
            }
            if #available(OSX 10.11, *) {
                if let allowsAirPlayForMediaPlayback: Bool = settingsWK["allowsAirPlayForMediaPlayback"] as? Bool {
                    self.allowsAirPlayForMediaPlayback = allowsAirPlayForMediaPlayback
                }
            }
#endif
            if let javaScriptEnabled: Bool = settingsWK["javaScriptEnabled"] as? Bool {
                self.preferences.javaScriptEnabled = javaScriptEnabled
            }
            if let javaScriptCanOpenWindowsAutomatically: Bool = settingsWK["javaScriptCanOpenWindowsAutomatically"] as? Bool {
                self.preferences.javaScriptCanOpenWindowsAutomatically = javaScriptCanOpenWindowsAutomatically
            }

            if let minimumFontSize: Double = settingsWK["minimumFontSize"] as? Double {
                self.preferences.minimumFontSize = CGFloat.init(minimumFontSize)
            }
            
        }


    }
}
