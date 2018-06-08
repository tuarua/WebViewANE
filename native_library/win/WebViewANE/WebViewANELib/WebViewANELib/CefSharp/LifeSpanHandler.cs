using System;
using CefSharp;

namespace WebViewANELib.CefSharp
{
    public class LifeSpanHandler : ILifeSpanHandler {
        public event EventHandler<string> OnPermissionPopup;
        public event EventHandler<string> OnPopupBlock;
        private readonly PopupBehaviour _popupBehaviour;
        private readonly Tuple<int, int> _popupDimensions;


        public LifeSpanHandler(PopupBehaviour popupBehaviour, Tuple<int, int> popupDimensions) {
            _popupBehaviour = popupBehaviour;
            _popupDimensions = popupDimensions;
        }

        public bool OnBeforePopup(IWebBrowser browserControl, IBrowser browser, IFrame frame, string targetUrl, string targetFrameName,
            WindowOpenDisposition targetDisposition, bool userGesture, IPopupFeatures popupFeatures, IWindowInfo windowInfo,
            IBrowserSettings browserSettings, ref bool noJavascriptAccess, out IWebBrowser newBrowser) {
            //Set newBrowser to null unless your attempting to host the popup in a new instance of ChromiumWebBrowser
            newBrowser = null;

            windowInfo.Width = _popupDimensions.Item1;
            windowInfo.Height = _popupDimensions.Item2;

            // ReSharper disable once ConvertIfStatementToSwitchStatement
            if (_popupBehaviour == PopupBehaviour.Block) {
                var handler = OnPopupBlock;
                handler?.Invoke(this, targetUrl);
                return true;
            }
            
            // ReSharper disable once InvertIf
            if (_popupBehaviour == PopupBehaviour.SameWindow) {
                var handler = OnPermissionPopup;
                handler?.Invoke(this, targetUrl);
                return true;
            }

            return false; //Return true to cancel the popup creation
        }

        public void OnAfterCreated(IWebBrowser browserControl, IBrowser browser) {
        }

        public bool DoClose(IWebBrowser browserControl, IBrowser browser) {
            //We need to allow popups to close
            //If the browser has been disposed then we'll just let the default behaviour take place

            return !browser.IsDisposed && !browser.IsPopup;

            //The default CEF behaviour (return false) will send a OS close notification (e.g. WM_CLOSE).
            //See the doc for this method for full details.
            //return true here to handle closing yourself (no WM_CLOSE will be sent).

        }

        public void OnBeforeClose(IWebBrowser browserControl, IBrowser browser) {
        }
    }
}