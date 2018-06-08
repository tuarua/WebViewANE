using System.Collections.Generic;
using CefSharp;
using CefSharp.Structs;

namespace WebViewANELib.CefSharp {
    public class DisplayHandler : IDisplayHandler {
        public void OnAddressChanged(IWebBrowser browserControl, AddressChangedEventArgs addressChangedArgs) { }

        public bool OnAutoResize(IWebBrowser browserControl, IBrowser browser, Size newSize) {
            return false;
        }

        public void OnTitleChanged(IWebBrowser browserControl, TitleChangedEventArgs titleChangedArgs) { }

        public void OnFaviconUrlChange(IWebBrowser browserControl, IBrowser browser, IList<string> urls) { }

        public void OnFullscreenModeChange(IWebBrowser browserControl, IBrowser browser, bool fullscreen) { }

        public bool OnTooltipChanged(IWebBrowser browserControl, ref string text) {
            return false;
        }

        public void OnStatusMessage(IWebBrowser browserControl, StatusMessageEventArgs statusMessageArgs) { }

        public bool OnConsoleMessage(IWebBrowser browserControl, ConsoleMessageEventArgs consoleMessageArgs) {
            return false;
        }
    }
}