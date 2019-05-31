using System;
using CefSharp;
using Newtonsoft.Json.Linq;
using TuaRua.FreSharp;

namespace WebViewANELib.CefSharp {
    public class KeyboardHandler : IKeyboardHandler {
        public event EventHandler<int> OnKeyEventFired;
        private const string OnKeyUp = "WebView.OnKeyUp";
        private const string OnKeyDown = "WebView.OnKeyDown";
        private readonly FreContextSharp _context;
        public bool HasKeyUp { set; private get; }
        public bool HasKeyDown { set; private get; }

        public KeyboardHandler(FreContextSharp context) {
            _context = context;
        }

        public bool OnPreKeyEvent(IWebBrowser browserControl, IBrowser browser, KeyType type, int windowsKeyCode,
            int nativeKeyCode,
            CefEventFlags modifiers, bool isSystemKey, ref bool isKeyboardShortcut) {
            return false;
        }

        public bool OnKeyEvent(IWebBrowser browserControl, IBrowser browser, KeyType type, int windowsKeyCode,
            int nativeKeyCode,
            CefEventFlags modifiers, bool isSystemKey) {
            if (KeyType.RawKeyDown != type && KeyType.KeyUp != type) return false;
            if (HasKeyUp && KeyType.KeyUp == type || HasKeyDown && KeyType.RawKeyDown == type) {
                var json = JObject.FromObject(new {
                    type,
                    keyCode = windowsKeyCode,
                    nativeKeyCode,
                    modifiers = modifiers.ToString(),
                    isSystemKey
                });
                _context.DispatchEvent(KeyType.KeyUp == type ? OnKeyUp : OnKeyDown, json.ToString());
            }

            if (windowsKeyCode != 27) return false;
            OnKeyEventFired?.Invoke(browserControl, windowsKeyCode);
            return false;
        }
    }
}