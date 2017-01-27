// Copyright © 2010-2016 The CefSharp Authors. All rights reserved.
//
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

using System;
using CefSharp;

namespace CefSharpLib {
    public class DownloadHandler : IDownloadHandler {
        public event EventHandler<DownloadItem> OnBeforeDownloadFired;
        public event EventHandler<DownloadItem> OnDownloadUpdatedFired;
        private CefPage _pc;
        public DownloadHandler(CefPage pc) {
            _pc = pc;
        }

        public void OnBeforeDownload(IBrowser browser, DownloadItem downloadItem, IBeforeDownloadCallback callback) {
            var handler = OnBeforeDownloadFired;
            Console.BackgroundColor = ConsoleColor.DarkRed;

            Console.WriteLine(@"OnBeforeDownload");
            handler?.Invoke(this, downloadItem);

            if (!callback.IsDisposed) {
                using (callback) {
                    callback.Continue(downloadItem.SuggestedFileName, true);
                }
            }
        }

        public void OnDownloadUpdated(IBrowser browser, DownloadItem downloadItem, IDownloadItemCallback callback) {
            Console.WriteLine(@"OnDownloadUpdated");
            var handler = OnDownloadUpdatedFired;
            handler?.Invoke(this, downloadItem);
        }

    }
}
