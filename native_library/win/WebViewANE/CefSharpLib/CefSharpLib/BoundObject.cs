using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Newtonsoft.Json;

namespace CefSharpLib {
    public class BoundObject {
        private const string JS_CALLBACK_EVENT = "TRWV.js.CALLBACK";
        private readonly CefPage _pc;
        public BoundObject(CefPage pc) {
            _pc = pc;
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

            Console.WriteLine();

            StringBuilder sb = new StringBuilder();
            StringWriter sw = new StringWriter(sb);
            JsonWriter writer = new JsonTextWriter(sw);

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

            Console.WriteLine(sb.ToString());
            _pc.SendMessage(JS_CALLBACK_EVENT, sb.ToString());
        }

    }
}