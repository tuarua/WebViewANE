// Copyright © 2010-2016 The CefSharp Authors. All rights reserved.
//
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

using System;
using CefSharp;

namespace WebViewANELib.CefSharp {
    public class DownloadHandler : IDownloadHandler {
        private readonly string _saveToDirectory;
        public event EventHandler<DownloadItem> OnBeforeDownloadFired;
        public event EventHandler<DownloadItem> OnDownloadUpdatedFired;

        public DownloadHandler(string saveToDirectory = null) {
            _saveToDirectory = saveToDirectory;
        }

        bool IDownloadHandler.OnBeforeDownload(IWebBrowser chromiumWebBrowser, IBrowser browser, DownloadItem downloadItem, IBeforeDownloadCallback callback) {
            OnBeforeDownloadFired?.Invoke(this, downloadItem);

            if (callback.IsDisposed) return true;
            var downloadPath = string.IsNullOrEmpty(_saveToDirectory)
                ? downloadItem.SuggestedFileName
                : _saveToDirectory + "\\" + downloadItem.SuggestedFileName;
            var showDialog = string.IsNullOrEmpty(_saveToDirectory);
            callback.Continue(downloadPath, showDialog);

            return true;
        }

        public void OnDownloadUpdated(IWebBrowser chromiumWebBrowser, IBrowser browser, DownloadItem downloadItem,
            IDownloadItemCallback callback) {
            OnDownloadUpdatedFired?.Invoke(chromiumWebBrowser, downloadItem);
        }

        public bool CanDownload(IWebBrowser chromiumWebBrowser, IBrowser browser, string url, string requestMethod) {
            return true;
        }
    }
}