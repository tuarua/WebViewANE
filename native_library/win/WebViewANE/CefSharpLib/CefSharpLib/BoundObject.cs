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
using System.Collections.Generic;
using System.IO;
using System.Text;
using Newtonsoft.Json;
using TuaRua.FreSharp;

namespace CefSharpLib {
    public class BoundObject {
        private const string JsCallbackEvent = "TRWV.js.CALLBACK";
        private readonly FreContextSharp _context;

        public BoundObject(FreContextSharp context) {
            _context = context;
        }

        public class JavascriptMessage {
            //public IJavascriptCallback Callback { get; set; }
            // ReSharper disable once InconsistentNaming
            public string functionName { get; set; }
            // ReSharper disable once InconsistentNaming
            public string callbackName { get; set; }
            // ReSharper disable once InconsistentNaming
            public IList<object> args { get; set; }
        }

        public void PostMessage(JavascriptMessage param) {

            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            writer.WriteStartObject();
            writer.WritePropertyName("functionName");
            writer.WriteValue(param.functionName);
            writer.WritePropertyName("args");

            if (param.args != null && param.args.Count > 0) {
                writer.WriteStartArray();
                foreach (var value in param.args) {
                    writer.WriteValue(value);
                }
                writer.WriteEndArray();
            } else {
                writer.WriteNull();
            }

            writer.WritePropertyName("callbackName");
            if (!string.IsNullOrEmpty(param.callbackName)) {
                writer.WriteValue(param.callbackName);
            } else {
                writer.WriteNull();
            }
            writer.WriteEndObject();
            _context.SendEvent(JsCallbackEvent, sb.ToString());
        }

    }
}