// Copyright © 2010-2016 The CefSharp Authors. All rights reserved.
//
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

using System;
using CefSharp;

namespace CefSharpLib {
    public class DownloadHandler : IDownloadHandler {
        public event EventHandler<DownloadItem> OnBeforeDownloadFired;
        public event EventHandler<DownloadItem> OnDownloadUpdatedFired;

        public void OnBeforeDownload(IBrowser browser, DownloadItem downloadItem, IBeforeDownloadCallback callback) {
            var handler = OnBeforeDownloadFired;
            handler?.Invoke(this, downloadItem);

            if (callback.IsDisposed) return;
            using (callback) {
                callback.Continue(downloadItem.SuggestedFileName, true);
            }
        }

        public void OnDownloadUpdated(IBrowser browser, DownloadItem downloadItem, IDownloadItemCallback callback) {
            var handler = OnDownloadUpdatedFired;
            handler?.Invoke(this, downloadItem);
        }

    }
}
