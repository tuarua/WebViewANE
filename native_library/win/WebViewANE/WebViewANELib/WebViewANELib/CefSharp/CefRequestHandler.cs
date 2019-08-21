using System;
using System.Collections;
using System.Linq;
using CefSharp;
using CefSharp.Handler;

namespace WebViewANELib.CefSharp {
    public sealed class CefRequestHandler : RequestHandler {
        private readonly ArrayList _whiteList;
        private readonly ArrayList _blackList;
        public event EventHandler<string> OnUrlBlockedFired;

        public CefRequestHandler(ArrayList whiteList, ArrayList blackList) {
            _whiteList = whiteList;
            _blackList = blackList;
        }

        private bool IsWhiteListBlocked(string url) {
            return _whiteList != null && _whiteList.Count != 0 &&
                   !_whiteList.Cast<string>().Any(s => url.ToLower().Contains(s.ToLower()));
        }

        private bool IsBlackListBlocked(string url) {
            return _blackList != null && _blackList.Count != 0 &&
                   _blackList.Cast<string>().Any(s => url.ToLower().Contains(s.ToLower()));
        }

        protected override bool OnBeforeBrowse(IWebBrowser chromiumWebBrowser, IBrowser browser, IFrame frame, IRequest request,
            bool userGesture,
            bool isRedirect) {
            if (!IsWhiteListBlocked(request.Url) && !IsBlackListBlocked(request.Url)) return false;
            OnUrlBlockedFired?.Invoke(chromiumWebBrowser, request.Url);
            return true;
        }

        protected override bool OnOpenUrlFromTab(IWebBrowser browserControl, IBrowser browser, IFrame frame,
            string targetUrl, WindowOpenDisposition targetDisposition, bool userGesture) {
            return false;
        }
        
        protected override IResourceRequestHandler GetResourceRequestHandler(IWebBrowser chromiumWebBrowser, IBrowser browser,
            IFrame frame, IRequest request, bool isNavigation, bool isDownload, string requestInitiator,
            ref bool disableDefaultHandling) {
            var manager = UrlRequestHeaderManager.GetInstance();
            var userHeaders = manager.Headers;
            if (userHeaders == null) return null;
            if (userHeaders.Count == 0) return null;
            try {
                var uri = new Uri(request.Url);
                var host = uri.Host;
                return !userHeaders.ContainsKey(host) ? null : new CefResourceRequestHandler();
            }
            catch {
                // ignored
            }

            return null;
        }
        
    }
}