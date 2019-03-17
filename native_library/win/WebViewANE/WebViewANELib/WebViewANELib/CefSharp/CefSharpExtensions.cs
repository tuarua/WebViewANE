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
//  No part, or derivative of this Air Native Extensions's code is permitted 
//  to be sold as the basis of a commercially packaged Air Native Extension which 
//  undertakes the same purpose as this software. That is, a WebView for Windows, 
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.

#endregion

using System;
using CefSharp;
using Newtonsoft.Json.Linq;

namespace WebViewANELib.CefSharp {
    public static class CefSharpExtensions {
        public static string ToJsonString(this JavascriptResponse response, string callbackName) {
            var json = JObject.FromObject(new {
                message = response.Message,
                error = (string) null,
                result = response.Success && response.Result != null
                    ? response.Result
                    : null as object,
                success = response.Success,
                callbackName
            });
            return json.ToString();
        }

        public static string ToJsonString(this Exception e, string guid) {
            var json = JObject.FromObject(new {
                message = (string) null,
                error = e.Message,
                result = (object) null,
                success = false,
                guid
            });
            return json.ToString();
        }

        public static string ToJsonString(this LoadErrorEventArgs e, int tab) {
            var json = JObject.FromObject(new {
                url = e.FailedUrl,
                errorCode = e.ErrorCode,
                errorText = e.ErrorText,
                tab
            });

            return json.ToString();
        }

        public static string ToJsonString(this DownloadItem downloadItem) {
            var json = JObject.FromObject(new {
                id = downloadItem.Id,
                url = downloadItem.OriginalUrl,
                speed = downloadItem.CurrentSpeed,
                percent = downloadItem.PercentComplete,
                bytesLoaded = downloadItem.ReceivedBytes,
                bytesTotal = downloadItem.TotalBytes
            });
            return json.ToString();
        }
    }
}