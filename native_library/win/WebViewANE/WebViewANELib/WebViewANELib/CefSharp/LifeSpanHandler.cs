using System;
using System.Collections;
using CefSharp;

namespace WebViewANELib.CefSharp {
    public class LifeSpanHandler : ILifeSpanHandler {
        public event EventHandler<string> OnPermissionPopup;
        public event EventHandler<string> OnPopupBlock;
        private readonly PopupBehaviour _popupBehaviour;
        private readonly Tuple<int, int> _popupDimensions;
        private readonly ArrayList _popUps = new ArrayList();

        public LifeSpanHandler(PopupBehaviour popupBehaviour, Tuple<int, int> popupDimensions) {
            _popupBehaviour = popupBehaviour;
            _popupDimensions = popupDimensions;
        }

        public bool OnBeforePopup(IWebBrowser browserControl, IBrowser browser, IFrame frame, string targetUrl,
            string targetFrameName,
            WindowOpenDisposition targetDisposition, bool userGesture, IPopupFeatures popupFeatures,
            IWindowInfo windowInfo,
            IBrowserSettings browserSettings, ref bool noJavascriptAccess, out IWebBrowser newBrowser) {

            //Set newBrowser to null unless your attempting to host the popup in a new instance of ChromiumWebBrowser
            newBrowser = null;

            windowInfo.Width = _popupDimensions.Item1;
            windowInfo.Height = _popupDimensions.Item2;
            EventHandler<string> handler;

            switch (_popupBehaviour) {
                case PopupBehaviour.NewWindow:
                    return false;
                case PopupBehaviour.Replace:
                    lock (_popUps.SyncRoot) {
                        try {
                            foreach (IBrowser p in _popUps) {
                                p.CloseBrowser(true);
                            }
                        }
                        catch {
                            // ignored
                        }
                    }

                    return false;
                case PopupBehaviour.Block:
                    handler = OnPopupBlock;
                    handler?.Invoke(this, targetUrl);
                    return true;
                case PopupBehaviour.SameWindow:
                    handler = OnPermissionPopup;
                    handler?.Invoke(this, targetUrl);
                    return true;
                default:
                    return false;
            }
        }

        public void OnAfterCreated(IWebBrowser browserControl, IBrowser browser) {
            // ReSharper disable once InvertIf
            if (_popupBehaviour == PopupBehaviour.Replace && browser.IsPopup) {
                lock (_popUps.SyncRoot) {
                    _popUps.Add(browser);
                }
            }
        }

        public bool DoClose(IWebBrowser browserControl, IBrowser browser) {
            // ReSharper disable once InvertIf
            if (_popupBehaviour == PopupBehaviour.Replace && browser.IsPopup) {
                lock (_popUps.SyncRoot) {
                    for (var i = 0; i < _popUps.Count; i++) {
                        var b = (IBrowser) _popUps[i];
                        if (b.Identifier == browser.Identifier) {
                            _popUps.RemoveAt(i);
                        }
                    }

                    _popUps.TrimToSize();
                }
            }

            return !browser.IsDisposed && !browser.IsPopup;
        }

        public void OnBeforeClose(IWebBrowser browserControl, IBrowser browser) { }
    }
}