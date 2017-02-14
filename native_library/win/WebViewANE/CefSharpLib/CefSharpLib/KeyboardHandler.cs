using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CefSharp;

namespace CefSharpLib {
    public class KeyboardHandler : IKeyboardHandler {

        public event EventHandler<int> OnKeyEventFired;

        public bool OnPreKeyEvent(IWebBrowser browserControl, IBrowser browser, KeyType type, int windowsKeyCode, int nativeKeyCode,
            CefEventFlags modifiers, bool isSystemKey, ref bool isKeyboardShortcut) {
            return false;
        }

        public bool OnKeyEvent(IWebBrowser browserControl, IBrowser browser, KeyType type, int windowsKeyCode, int nativeKeyCode,
            CefEventFlags modifiers, bool isSystemKey) {
            if (windowsKeyCode != 27) return false;
            var handler = OnKeyEventFired;
            handler?.Invoke(this, windowsKeyCode);
            return false;
        }

    }
}
