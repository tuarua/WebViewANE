using System.Collections.Generic;
using CefSharp;

namespace CefSharpLib {
    public class DisplayHandler : IDisplayHandler {
        public void OnAddressChanged(IWebBrowser browserControl, AddressChangedEventArgs addressChangedArgs) { }

        public void OnTitleChanged(IWebBrowser browserControl, TitleChangedEventArgs titleChangedArgs) { }

        public void OnFaviconUrlChange(IWebBrowser browserControl, IBrowser browser, IList<string> urls) { }

        public void OnFullscreenModeChange(IWebBrowser browserControl, IBrowser browser, bool fullscreen) { }

        public bool OnTooltipChanged(IWebBrowser browserControl, string text) {
            return false;
        }

        public void OnStatusMessage(IWebBrowser browserControl, StatusMessageEventArgs statusMessageArgs) { }

        public bool OnConsoleMessage(IWebBrowser browserControl, ConsoleMessageEventArgs consoleMessageArgs) {
            return false;
        }
    }
}