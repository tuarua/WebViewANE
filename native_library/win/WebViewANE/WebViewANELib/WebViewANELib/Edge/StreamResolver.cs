#region License

// Copyright 2017 Tua Rua Ltd.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 
//  Additional Terms
//  No part, or derivative of this Air Native Extensions's code is permitted 
//  to be sold as the basis of a commercially packaged Air Native Extension which 
//  undertakes the same purpose as this software. That is, a WebView for Windows, 
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.

#endregion

using System;
using System.IO;
using System.Text;
using Microsoft.Toolkit.Win32.UI.Controls.Interop.WinRT;

namespace WebViewANELib.Edge {
    public class StreamResolver : IUriToStreamResolver {
        private readonly string _allowingReadAccessTo;
        private const int MaxPathLength = 2048;
        private const int MaxSchemeLength = 32;
        private const int MaxUrlLength = MaxPathLength + MaxSchemeLength + 3; /*=sizeof("://")*/

        public StreamResolver(string allowingReadAccessTo) {
            _allowingReadAccessTo = allowingReadAccessTo;
        }

        public Stream UriToStream(Uri uri) {
            var rel = RelativeUriToString(uri).Replace("/", "\\");
            return File.Open(_allowingReadAccessTo + rel, FileMode.Open, FileAccess.Read);
        }

        internal static string RelativeUriToString(Uri uri) {
            return new StringBuilder(
                uri.GetComponents(UriComponents.PathAndQuery, 
                    UriFormat.SafeUnescaped), 
                MaxUrlLength).ToString();
        }
    }
}