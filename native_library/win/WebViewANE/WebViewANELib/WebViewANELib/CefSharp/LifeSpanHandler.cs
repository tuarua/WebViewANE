using System;
using System.Collections;
using CefSharp;
using System.Diagnostics;
using WinApi = TuaRua.FreSharp.Utils.WinApi;

namespace WebViewANELib.CefSharp {
    public class LifeSpanHandler : ILifeSpanHandler {
        public event EventHandler<string> OnPermissionPopup;
        public event EventHandler<string> OnPopupBlock;
        private readonly PopupBehaviour _popupBehaviour;
        private readonly Tuple<int, int> _popupDimensions;
        public double ScaleFactor { get; set; }
        private readonly ArrayList _popUps = new ArrayList();

        public LifeSpanHandler(PopupBehaviour popupBehaviour, Tuple<int, int> popupDimensions, double scaleFactor) {
            _popupBehaviour = popupBehaviour;
            _popupDimensions = popupDimensions;
            ScaleFactor = scaleFactor;
        }

        public bool OnBeforePopup(IWebBrowser browserControl, IBrowser browser, IFrame frame, string targetUrl,
            string targetFrameName,
            WindowOpenDisposition targetDisposition, bool userGesture, IPopupFeatures popupFeatures,
            IWindowInfo windowInfo,
            IBrowserSettings browserSettings, ref bool noJavascriptAccess, out IWebBrowser newBrowser) {
            //Set newBrowser to null unless your attempting to host the popup in a new instance of ChromiumWebBrowser
            newBrowser = null;

            windowInfo.Width = Convert.ToInt32((popupFeatures.Width > 0 ? popupFeatures.Width : _popupDimensions.Item1) * ScaleFactor);
            windowInfo.Height = Convert.ToInt32((popupFeatures.Height > 0 ? popupFeatures.Height : _popupDimensions.Item2) * ScaleFactor);
            
            var popX = popupFeatures.X ?? -1;
            if (popX == -1) {
                var rect = new WinApi.Rect();
                var mainWindow = Process.GetCurrentProcess().MainWindowHandle;
                if (mainWindow != IntPtr.Zero) {
                    WinApi.GetWindowRect(Process.GetCurrentProcess().MainWindowHandle, ref rect);
                    windowInfo.X = rect.left + 50;
                    windowInfo.Y = rect.top + 50;
                }
            }

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
                    handler?.Invoke(browserControl, targetUrl);
                    return true;
                case PopupBehaviour.SameWindow:
                    handler = OnPermissionPopup;
                    handler?.Invoke(browserControl, targetUrl);
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