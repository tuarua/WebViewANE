using System;
using CefSharp;
using TuaRua.FreSharp;
using System.Text;
using System.IO;
using Newtonsoft.Json;

namespace CefSharpLib {
    public class KeyboardHandler : IKeyboardHandler {
        public event EventHandler<int> OnKeyEventFired;
        private const string OnKeyUp = "WebView.OnKeyUp";
        private const string OnKeyDown = "WebView.OnKeyDown";
        private readonly FreContextSharp _context;
        public bool HasKeyUp { set; get; }
        public bool HasKeyDown { set; get; }

        public KeyboardHandler(FreContextSharp context) {
            _context = context;
        }

        public bool OnPreKeyEvent(IWebBrowser browserControl, IBrowser browser, KeyType type, int windowsKeyCode, int nativeKeyCode,
            CefEventFlags modifiers, bool isSystemKey, ref bool isKeyboardShortcut) {
            return false;
        }

        public bool OnKeyEvent(IWebBrowser browserControl, IBrowser browser, KeyType type, int windowsKeyCode, int nativeKeyCode,
            CefEventFlags modifiers, bool isSystemKey) {
            if(KeyType.RawKeyDown != type && KeyType.KeyUp != type) return false;
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            if ((HasKeyUp && KeyType.KeyUp == type) || (HasKeyDown && KeyType.RawKeyDown == type)) {
                
                writer.WriteStartObject();
                writer.WritePropertyName("type");
                writer.WriteValue(type);
                writer.WritePropertyName("keyCode");
                writer.WriteValue(windowsKeyCode);
                writer.WritePropertyName("nativeKeyCode");
                writer.WriteValue(nativeKeyCode);
                writer.WritePropertyName("modifiers");
                writer.WriteValue(modifiers.ToString());
                writer.WritePropertyName("isSystemKey");
                writer.WriteValue(isSystemKey);
                writer.WriteEndObject();
                _context.SendEvent(KeyType.KeyUp == type ? OnKeyUp : OnKeyDown, sb.ToString());
            }

            if (windowsKeyCode != 27) return false;
            var handler = OnKeyEventFired;
            handler?.Invoke(this, windowsKeyCode);
            return false;
        }

    }
}
