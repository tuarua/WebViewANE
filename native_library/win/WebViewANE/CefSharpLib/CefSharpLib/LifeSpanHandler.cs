using System;
using CefSharp;

namespace CefSharpLib {
    public class LifeSpanHandler : ILifeSpanHandler {
        public event EventHandler<string> OnPermissionPopup;
        private readonly PopupBehaviour _type;
        public LifeSpanHandler(PopupBehaviour type) {
            _type = type;
        }

        public bool OnBeforePopup(IWebBrowser browserControl, IBrowser browser, IFrame frame, string targetUrl, string targetFrameName,
            WindowOpenDisposition targetDisposition, bool userGesture, IPopupFeatures popupFeatures, IWindowInfo windowInfo,
            IBrowserSettings browserSettings, ref bool noJavascriptAccess, out IWebBrowser newBrowser) {
            //Set newBrowser to null unless your attempting to host the popup in a new instance of ChromiumWebBrowser
            newBrowser = null;

            // ReSharper disable once ConvertIfStatementToSwitchStatement
            if (_type == PopupBehaviour.Block) {
                return true;
            }
            
            // ReSharper disable once InvertIf
            if (_type == PopupBehaviour.SameWindow) {
                var handler = OnPermissionPopup;
                handler?.Invoke(this, targetUrl);
                return true;
            }

            return false; //Return true to cancel the popup creation
        }

        public void OnAfterCreated(IWebBrowser browserControl, IBrowser browser) {
            FreSharpController.FreHelper.DispatchEvent("TRACE", "OnAfterCreated");
        }

        public bool DoClose(IWebBrowser browserControl, IBrowser browser) {
            //We need to allow popups to close
            //If the browser has been disposed then we'll just let the default behaviour take place

            FreSharpController.FreHelper.DispatchEvent("TRACE", "DoClose");

            return !browser.IsDisposed && !browser.IsPopup;

            //The default CEF behaviour (return false) will send a OS close notification (e.g. WM_CLOSE).
            //See the doc for this method for full details.
            //return true here to handle closing yourself (no WM_CLOSE will be sent).



        }

        public void OnBeforeClose(IWebBrowser browserControl, IBrowser browser) {
            FreSharpController.FreHelper.DispatchEvent("TRACE", "OnBeforeClose");
        }
    }
}