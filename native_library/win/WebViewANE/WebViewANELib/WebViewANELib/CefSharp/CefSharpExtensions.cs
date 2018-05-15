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
using System.IO;
using System.Text;
using CefSharp;
using Newtonsoft.Json;

namespace WebViewANELib.CefSharp {
    public static class CefSharpExtensions {
        public static string ToJsonString(this JavascriptResponse response, string callback) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            JsonWriter writer = new JsonTextWriter(sw) {Formatting = Formatting.None};
            writer.WriteStartObject();
            writer.WritePropertyName("success");
            writer.WriteValue(response.Success);
            writer.WritePropertyName("message");
            writer.WriteValue(response.Message);
            writer.WritePropertyName("error");
            writer.WriteNull();
            writer.WritePropertyName("callbackName");
            writer.WriteValue(callback);
            writer.WritePropertyName("result");

            if (response.Success && response.Result != null) {
                writer.WriteRawValue(JsonConvert.SerializeObject(response.Result, Formatting.None));
            }
            else {
                writer.WriteNull();
            }

            writer.WriteEndObject();
            return sb.ToString();
        }

        public static string ToJsonString(this Exception e, string callback) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            JsonWriter writer = new JsonTextWriter(sw) {Formatting = Formatting.None};
            writer.WriteStartObject();
            writer.WritePropertyName("message");
            writer.WriteNull();
            writer.WritePropertyName("error");
            writer.WriteValue(e.Message);
            writer.WritePropertyName("result");
            writer.WriteNull();
            writer.WritePropertyName("success");
            writer.WriteValue(false);
            writer.WritePropertyName("guid");
            writer.WriteValue(callback);
            writer.WriteEndObject();
            return sb.ToString();
        }

        public static string ToJsonString(this LoadErrorEventArgs e, int tab) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            JsonWriter writer = new JsonTextWriter(sw) {Formatting = Formatting.None};
            writer.WriteStartObject();
            writer.WritePropertyName("url");
            writer.WriteValue(e.FailedUrl);
            writer.WritePropertyName("errorCode");
            writer.WriteValue(e.ErrorCode);
            writer.WritePropertyName("errorText");
            writer.WriteValue(e.ErrorText);
            writer.WritePropertyName("tab");
            writer.WriteValue(tab);
            writer.WriteEndObject();
            return sb.ToString();
        }

        public static string ToJsonString(this DownloadItem downloadItem) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            writer.WriteStartObject();
            writer.WritePropertyName("id");
            writer.WriteValue(downloadItem.Id);
            writer.WritePropertyName("url");
            writer.WriteValue(downloadItem.OriginalUrl);
            writer.WritePropertyName("speed");
            writer.WriteValue(downloadItem.CurrentSpeed);
            writer.WritePropertyName("percent");
            writer.WriteValue(downloadItem.PercentComplete);
            writer.WritePropertyName("bytesLoaded");
            writer.WriteValue(downloadItem.ReceivedBytes);
            writer.WritePropertyName("bytesTotal");
            writer.WriteValue(downloadItem.TotalBytes);
            writer.WriteEndObject();
            return sb.ToString();
        }
    }
}