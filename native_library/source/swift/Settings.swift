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
#if os(OSX)
    import Cocoa
#endif

public struct Settings {
    private var _configuration: Configuration
    private var _userAgent: String?
    private var _urlWhiteList: NSArray?
    private var _urlBlackList: NSArray?

    public var configuration: Configuration {
        return _configuration
    }

    public var userAgent: String? {
        return _userAgent
    }

    public var urlWhiteList: NSArray? {
        return _urlWhiteList
    }
    
    public var urlBlackList: NSArray? {
        return _urlBlackList
    }

    init(dictionary: [String: AnyObject]) {
        _configuration = Configuration.init(dictionary: dictionary)
        #if os(iOS)
            if let ce: Bool = dictionary["cacheEnabled"] as? Bool {
                _configuration.websiteDataStore = ce ? WKWebsiteDataStore.default() : WKWebsiteDataStore.nonPersistent()
            }
        #else
            if #available(OSX 10.11, *) {
                if let ce: Bool = dictionary["cacheEnabled"] as? Bool {
                    _configuration.websiteDataStore = ce
                        ? WKWebsiteDataStore.default()
                        : WKWebsiteDataStore.nonPersistent()
                }
            } else {
                // Fallback on earlier versions
            }
        #endif

        if let ua: String = dictionary["userAgent"] as? String {
            _userAgent = ua
        }

        if let uwl: NSArray = dictionary["urlWhiteList"] as? NSArray {
            _urlWhiteList = uwl
        }
        
        if let ubl: NSArray = dictionary["urlBlackList"] as? NSArray {
            _urlBlackList = ubl
        }

    }
}
