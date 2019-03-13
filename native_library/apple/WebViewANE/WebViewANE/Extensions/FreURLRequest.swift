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

public extension URLRequest {
    init?(_ freObject: FREObject?) {
        guard let rv = freObject else { return nil }
        let fre = FreObjectSwift(rv)
        guard let urlStr: String = fre.url, let url = URL(string: urlStr) else { return nil }
        self.init(url: url)
        for header in URLRequest.getCustomRequestHeaders(rv) {
            self.addValue(header.1, forHTTPHeaderField: header.0)
        }
    }
    
    public static func getCustomRequestHeaders(_ freObject: FREObject?) -> [(String, String)] {
        var ret = [(String, String)]()
        guard let rv = freObject else { return ret }
        if let freRequestHeaders = rv["requestHeaders"] {
            let arr = FREArray(freRequestHeaders)
            for requestHeaderFre in arr {
                if let name = String(requestHeaderFre["name"]), let value = String(requestHeaderFre["value"]) {
                    ret.append((name, value))
                }
            }
        }
        return ret
    }
    
}
