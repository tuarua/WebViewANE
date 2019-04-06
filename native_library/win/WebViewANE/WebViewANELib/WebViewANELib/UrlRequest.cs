#region License

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
//  No part, or derivative of this Air Native Extension's code is permitted 
//  to be sold as the basis of a commercially packaged Air Native Extension which 
//  undertakes the same purpose as this software. That is, a WebView for Windows, 
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.

#endregion

using System.Collections.Generic;
using System.Linq;
using FREObject = System.IntPtr;
using TuaRua.FreSharp;

namespace WebViewANELib {
    public class UrlRequest {
        public string Url { get; }
        public List<KeyValuePair<string, string>> RequestHeaders { get; }

        private readonly string[] _acceptedHeaders = {
            "accept", "accept-encoding", "accept-language", "authorization",
            "cache-control", "connection", "cookie", "date", "from", "host", "if-modified-since",
            "if-unmodified-since", "max-forwards", "proxy-authorization", "referer", "user-agent"
        };

        public UrlRequest(FREObject freObject, bool usingEdge) {
            RequestHeaders = new List<KeyValuePair<string, string>>();
            if (freObject.Type() == FreObjectTypeSharp.Null) return;
            Url = freObject.GetProp("url").AsString();
            var requestHeadersFre = new FREArray(freObject.GetProp("requestHeaders"));
            foreach (var requestHeader in requestHeadersFre) {
                var rh = new UrlRequestHeader(requestHeader);
                if (usingEdge && !_acceptedHeaders.Contains(rh.Name.ToLower())) {
                    continue;
                }

                RequestHeaders.Add(new KeyValuePair<string, string>(rh.Name, rh.Value));
            }
        }

        public UrlRequest(string url) {
            Url = url;
            RequestHeaders = new List<KeyValuePair<string, string>>();
        }
    }
}