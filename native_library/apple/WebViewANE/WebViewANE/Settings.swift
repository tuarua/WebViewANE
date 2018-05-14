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

public struct Settings {
    private var _configuration = Configuration()
    private var _userAgent: String?
    private var _urlWhiteList: [String] = []
    private var _urlBlackList: [String] = []
    private var _enableDownloads = false
    private var _hasContextMenu = true
    private var _downloadPath: String?
    private var _popupBehaviour = PopupBehaviour.newWindow
    private var _popupDimensions = (800, 600)
    
    public var enableDownloads: Bool {
        return _enableDownloads
    }
    
    public var downloadPath: String? {
        return _downloadPath
    }
    
    public var configuration: Configuration {
        return _configuration
    }

    public var userAgent: String? {
        return _userAgent
    }

    public var urlWhiteList: [String] {
        return _urlWhiteList
    }
    
    public var urlBlackList: [String] {
        return _urlBlackList
    }
    
    public var popupBehaviour: PopupBehaviour {
        return _popupBehaviour
    }
    
    public var popupDimensions: (Int, Int) {
        return _popupDimensions
    }
    
    public var hasContextMenu: Bool {
        return _hasContextMenu
    }
    
    init?(_ freObject: FREObject?) {
        guard let rv = freObject,
            let urlWhiteList = [String](rv["urlWhiteList"]),
            let urlBlackList = [String](rv["urlBlackList"]),
            let enableDownloads = Bool(rv["enableDownloads"]),
            let cacheEnabled = Bool(rv["cacheEnabled"]),
            let contextMenu = rv["contextMenu"],
            let hasContextMenu = Bool(contextMenu["enabled"]),
            let popup = rv["popup"],
            let behaviour = Int(popup["behaviour"]),
            let popupBehaviour = PopupBehaviour(rawValue: behaviour),
            let dimensions = popup["dimensions"],
            let popupW = Int(dimensions["width"]),
            let popupH = Int(dimensions["height"])
            else { return }
        
        _downloadPath = String(rv["downloadPath"])
        _configuration = Configuration(rv["webkit"])
        _userAgent = String(rv["userAgent"])
        _urlWhiteList = urlWhiteList
        _urlBlackList = urlBlackList
        _enableDownloads = enableDownloads
        _hasContextMenu = hasContextMenu
        _popupBehaviour = popupBehaviour
        _popupDimensions = (popupW, popupH)
#if os(iOS)
        _configuration.websiteDataStore = cacheEnabled
            ? WKWebsiteDataStore.default()
            : WKWebsiteDataStore.nonPersistent()
#else
        if #available(OSX 10.11, *) {
            _configuration.websiteDataStore = cacheEnabled
                ? WKWebsiteDataStore.default()
                : WKWebsiteDataStore.nonPersistent()
        }
#endif
    }
}
