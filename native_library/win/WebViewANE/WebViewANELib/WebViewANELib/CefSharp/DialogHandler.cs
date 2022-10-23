// Copyright © 2010-2017 The CefSharp Authors. All rights reserved.
//
// Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

using System.Collections.Generic;
using CefSharp;

namespace WebViewANELib.CefSharp {
    public class DialogHandler : IDialogHandler
    {
        public bool Disabled { get; internal set; }

        public bool OnFileDialog(IWebBrowser chromiumWebBrowser, IBrowser browser, CefFileDialogMode mode, string title, string defaultFilePath, List<string> acceptFilters, IFileDialogCallback callback) {
            return Disabled;
        }
    }
}