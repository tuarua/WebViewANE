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
//  All Rights Reserved. Tua Rua Ltd.
#endregion

using System;
using System.Collections.Generic;

namespace WebViewANELib {
    public class UrlRequestHeaderManager {
        private static volatile UrlRequestHeaderManager _instance;

        // Lock synchronization object
        private static readonly object SyncLock = new object();

        // Constructor (protected)
        protected UrlRequestHeaderManager() {
            Headers = new Dictionary<string, List<UrlRequestHeader>>();
        }

        public static UrlRequestHeaderManager GetInstance() {
            if (_instance != null) return _instance;
            lock (SyncLock) {
                if (_instance == null) {
                    _instance = new UrlRequestHeaderManager();
                }
            }

            return _instance;
        }

        public Dictionary<string, List<UrlRequestHeader>> Headers { get; }
        public bool PersistRequestHeaders { get; set; }
        public void Add(UrlRequest urlRequest) {
            var uri = new Uri(urlRequest.Url);
            if (urlRequest.RequestHeaders.Count == 0) {
                Headers.Remove(uri.Host);
                return;
            }

            if (Headers.ContainsKey(uri.Host)) {
                Headers[uri.Host] = urlRequest.RequestHeaders;
            }
            else {
                Headers.Add(uri.Host, urlRequest.RequestHeaders);
            }
        }

        public void Remove(string host) {
            if (Headers.ContainsKey(host)) {
                Headers.Remove(host);
            }
        }

        public void Remove() {
            Headers.Clear();
        }

    }
}