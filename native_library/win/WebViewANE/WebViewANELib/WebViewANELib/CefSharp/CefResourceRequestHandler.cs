using System;
using CefSharp;
using CefSharp.Handler;

namespace WebViewANELib.CefSharp {
    public class CefResourceRequestHandler : ResourceRequestHandler {
        protected override CefReturnValue OnBeforeResourceLoad(IWebBrowser chromiumWebBrowser, IBrowser browser,
            IFrame frame, IRequest request, IRequestCallback callback) {
            var manager = UrlRequestHeaderManager.GetInstance();
            var userHeaders = manager.Headers;
            if (userHeaders == null) return CefReturnValue.Continue;
            if (userHeaders.Count == 0) return CefReturnValue.Continue;
            try {
                var uri = new Uri(request.Url);
                var host = uri.Host;
                var domainHeaders = userHeaders[host];
                var headers = request.Headers;
                foreach (var domainHeader in domainHeaders) {
                    headers[domainHeader.Key] = domainHeader.Value;
                }

                request.Headers = headers;
                if (!manager.PersistRequestHeaders) {
                    manager.Remove(host);
                }
            }
            catch {
                // ignored
            }
            return CefReturnValue.Continue;
        }
    }
}