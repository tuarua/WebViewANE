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
//  No part, or derivative of this Air Native Extension's code is permitted 
//  to be sold as the basis of a commercially packaged Air Native Extension which 
//  undertakes the same purpose as this software. That is, a WebView for Windows, 
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.

#endregion
using System.Collections;
namespace WebViewANELib {
    internal interface IWebView {
        void Init();
        int CurrentTab { get; }
        int X { get; set; }
        int Y { get; set; }
        int ViewWidth { get; set; }
        int ViewHeight { get; set; }
        string InjectCode { set; }
        string InjectScriptUrl { set; }
        int InjectStartLine { set; }
        UrlRequest InitialUrl { set; }
        ArrayList WhiteList { set; }
        ArrayList BlackList { set; }
        void AddTab();
        void CloseTab(int index);
        void SetCurrentTab(int index);
        ArrayList TabDetails { get; }
        void Load(UrlRequest url, string allowingReadAccessTo);
        void LoadHtmlString(string html, UrlRequest url);
        void ZoomIn();
        void ZoomOut();
        void ForceFocus();
        void Reload(bool ignoreCache = false);
        void Stop();
        void Back();
        void Forward();
        void Print();
        void PrintToPdfAsync(string path);
        void AddEventListener(string type);
        void RemoveEventListener(string type);
        void ShowDevTools();
        void CloseDevTools();
        void EvaluateJavaScript(string javascript, string callback);
        void EvaluateJavaScript(string javascript);
        void DeleteCookies();
    }
}