using System;
using System.Collections;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using CefSharp;

namespace CefSharpLib {
    public class RequestHandler : IRequestHandler {
        private readonly ArrayList _whiteList;
        private readonly ArrayList _blackList;
        public event EventHandler<string> OnUrlBlockedFired;

        public RequestHandler(ArrayList whiteList, ArrayList blackList) {
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

        bool IRequestHandler.OnBeforeBrowse(IWebBrowser browserControl, IBrowser browser, IFrame frame,
            IRequest request, bool isRedirect) {
            if (!IsWhiteListBlocked(request.Url) && !IsBlackListBlocked(request.Url)) return false;
            var handler = OnUrlBlockedFired;
            handler?.Invoke(this, request.Url);
            return true;
        }

        bool IRequestHandler.OnOpenUrlFromTab(IWebBrowser browserControl, IBrowser browser, IFrame frame,
            string targetUrl, WindowOpenDisposition targetDisposition, bool userGesture) {
            return OnOpenUrlFromTab(browserControl, browser, frame, targetUrl, targetDisposition, userGesture);
        }

        protected virtual bool OnOpenUrlFromTab(IWebBrowser browserControl, IBrowser browser, IFrame frame,
            string targetUrl, WindowOpenDisposition targetDisposition, bool userGesture) {
            return false;
        }

        bool IRequestHandler.OnCertificateError(IWebBrowser browserControl, IBrowser browser, CefErrorCode errorCode,
            string requestUrl, ISslInfo sslInfo, IRequestCallback callback) {
            return false;
        }

        void IRequestHandler.OnPluginCrashed(IWebBrowser browserControl, IBrowser browser, string pluginPath) {
            // TODO: Add your own code here for handling scenarios where a plugin crashed, for one reason or another.
        }

        CefReturnValue IRequestHandler.OnBeforeResourceLoad(IWebBrowser browserControl, IBrowser browser, IFrame frame,
            IRequest request, IRequestCallback callback) {
            return CefReturnValue.Continue;
        }

        bool IRequestHandler.GetAuthCredentials(IWebBrowser browserControl, IBrowser browser, IFrame frame,
            bool isProxy, string host, int port, string realm, string scheme, IAuthCallback callback) {
            return false;
        }

        bool IRequestHandler.OnSelectClientCertificate(IWebBrowser browserControl, IBrowser browser, bool isProxy,
            string host, int port, X509Certificate2Collection certificates, ISelectClientCertificateCallback callback) {
            return false;
        }

        protected virtual bool OnSelectClientCertificate(IWebBrowser browserControl, IBrowser browser, bool isProxy,
            string host, int port, X509Certificate2Collection certificates, ISelectClientCertificateCallback callback) {
            callback.Dispose();
            return false;
        }

        void IRequestHandler.OnRenderProcessTerminated(IWebBrowser browserControl, IBrowser browser,
            CefTerminationStatus status) { }

        bool IRequestHandler.OnQuotaRequest(IWebBrowser browserControl, IBrowser browser, string originUrl,
            long newSize, IRequestCallback callback) {
            return false;
        }

        void IRequestHandler.OnResourceRedirect(IWebBrowser browserControl, IBrowser browser, IFrame frame,
            IRequest request, IResponse response, ref string newUrl) { }

        bool IRequestHandler.OnProtocolExecution(IWebBrowser browserControl, IBrowser browser, string url) {
            return false;
        }

        void IRequestHandler.OnRenderViewReady(IWebBrowser browserControl, IBrowser browser) { }

        bool IRequestHandler.OnResourceResponse(IWebBrowser browserControl, IBrowser browser, IFrame frame,
            IRequest request, IResponse response) {
            return false;
        }

        IResponseFilter IRequestHandler.GetResourceResponseFilter(IWebBrowser browserControl, IBrowser browser,
            IFrame frame, IRequest request, IResponse response) {
            return null;
        }

        void IRequestHandler.OnResourceLoadComplete(IWebBrowser browserControl, IBrowser browser, IFrame frame,
            IRequest request, IResponse response, UrlRequestStatus status, long receivedContentLength) { }
    }
}