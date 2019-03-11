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
using System;
using System.Collections;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows;
using Microsoft.Toolkit.Win32.UI.Controls.Interop.WinRT;
using Microsoft.Toolkit.Wpf.UI.Controls;
using Newtonsoft.Json.Linq;
using TuaRua.FreSharp;
using WebViewANELib.Edge;

namespace WebViewANELib {
    public partial class EdgeView : IWebView {
        public int CurrentTab { get; private set; }
        public ArrayList TabDetails { get; } = new ArrayList();
        private readonly ArrayList _tabs = new ArrayList();
        public int X { get; set; }
        public int Y { get; set; }
        public int ViewWidth { get; set; }
        public int ViewHeight { get; set; }
        public string InjectCode { get; set; }
        public string InjectScriptUrl { get; set; }
        public int InjectStartLine { get; set; }
        public UrlRequest InitialUrl { private get; set; }
        public ArrayList WhiteList { private get; set; }
        public ArrayList BlackList { private get; set; }
        public WebView CurrentBrowser { get; private set; }

        public static FreContextSharp Context;

        public void Init() {
            InitializeComponent();
            IsManipulationEnabled = true;
            var browser = CreateNewBrowser();
            CurrentBrowser = browser;
            MainGrid.Children.Add(CurrentBrowser);
        }

        private WebView CreateNewBrowser() {
            // ReSharper disable once UseObjectOrCollectionInitializer
            var browser = new WebView {
                VerticalAlignment = VerticalAlignment.Stretch,
                HorizontalAlignment = HorizontalAlignment.Stretch,
                IsJavaScriptEnabled = true,
                IsIndexedDBEnabled = true,
                IsPrivateNetworkClientServerCapabilityEnabled = true,
                IsScriptNotifyAllowed = true,
            };

            browser.NavigationStarting += OnNavigationStarting;
            browser.ContentLoading += OnBrowserLoadingStateChanged;
            browser.DOMContentLoaded += OnBrowserTitleChanged;
            browser.NavigationCompleted += OnNavigationCompleted;
            browser.NewWindowRequested += OnNewWindowRequested;
            browser.ScriptNotify += OnScriptNotify;
            browser.Loaded+= OnLoaded;

            _tabs.Add(browser);
            TabDetails.Add(new TabDetails());

            return browser;
        }

        private void OnLoaded(object sender, RoutedEventArgs e) {
            if (InitialUrl != null && !string.IsNullOrEmpty(InitialUrl.Url)) {
                CurrentBrowser.Navigate(new Uri(InitialUrl.Url));
            }
        }

        private static void OnScriptNotify(object sender, WebViewControlScriptNotifyEventArgs e) {
            Context.DispatchEvent(WebViewEvent.JsCallbackEvent, e.Value);
        }

        private void OnNavigationStarting(object sender, WebViewControlNavigationStartingEventArgs e) {
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(sender)) continue;
                var tabDetails = GetTabDetails(index);
                var url = e.Uri.AbsoluteUri;
                if (!IsWhiteListBlocked(url) && !IsBlackListBlocked(url)) {
                    if (tabDetails.Address == url) {
                        return;
                    }

                    tabDetails.Address = url;
                    SendPropertyChange(@"url", url, index);
                }
                else {
                    e.Cancel = true;
                    const int tab = 0;
                    var json = JObject.FromObject(new {url, tab});
                    Context.DispatchEvent(WebViewEvent.OnUrlBlocked, json.ToString());
                }
            }
        }

        private void OnBrowserLoadingStateChanged(object sender, WebViewControlContentLoadingEventArgs e) {
            var browser = (WebView) sender;
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(browser)) continue;
                var tabDetails = GetTabDetails(index);
                if (tabDetails.IsLoading) {
                    return;
                }

                tabDetails.IsLoading = true;
                SendPropertyChange(@"isLoading", true, index);

                if (tabDetails.CanGoForward != browser.CanGoForward) {
                    tabDetails.CanGoForward = browser.CanGoForward;
                    SendPropertyChange(@"canGoForward", browser.CanGoForward, index);
                }

                if (tabDetails.CanGoBack == browser.CanGoBack) return;

                tabDetails.CanGoBack = browser.CanGoBack;
                SendPropertyChange(@"canGoBack", browser.CanGoBack, index);
            }
        }

        private void OnBrowserTitleChanged(object sender, WebViewControlDOMContentLoadedEventArgs e) {
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(sender)) continue;
                var tabDetails = GetTabDetails(index);
                if (tabDetails.Title == CurrentBrowser.DocumentTitle) {
                    return;
                }

                tabDetails.Title = CurrentBrowser.DocumentTitle;
                SendPropertyChange(@"title", CurrentBrowser.DocumentTitle, index);
            }
        }

        private void OnNavigationCompleted(object sender, WebViewControlNavigationCompletedEventArgs e) {
            if (!e.IsSuccess) {
                var json = JObject.FromObject(new {
                    url = e.Uri,
                    errorCode = e.WebErrorStatus,
                    errorText = e.WebErrorStatus.ToString(),
                    tab = 0
                });
                Context.DispatchEvent(WebViewEvent.OnFail, json.ToString());
                return;
            }

            var browser = (WebView) sender;

            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(browser)) continue;
                var tabDetails = GetTabDetails(index);
                if (!tabDetails.IsLoading)  return;

                tabDetails.IsLoading = false;
                SendPropertyChange(@"isLoading", false, index);
            }
        }

        private void OnNewWindowRequested(object sender, WebViewControlNewWindowRequestedEventArgs e) {
            Load(e.Uri.ToString());
        }

        private TabDetails GetTabDetails(int tab) {
            return (TabDetails) TabDetails[tab];
        }

        public void AddTab() {
            Context.DispatchEvent("TRACE", "AddTab Unavailable in Edge");
        }

        public void SetCurrentTab(int index) {
            Context.DispatchEvent("TRACE", "SetCurrentTab Unavailable in Edge");
        }

        public void CloseTab(int index) {
            Context.DispatchEvent("TRACE", "CloseTab Unavailable in Edge");
        }

        private static void SendPropertyChange(string propName, bool value, int tab) {
            var json = JObject.FromObject(new {propName, value, tab});
            Context.DispatchEvent(WebViewEvent.OnPropertyChange, json.ToString());
        }

        private static void SendPropertyChange(string propName, string value, int tab) {
            var json = JObject.FromObject(new {propName, value, tab});
            Context.DispatchEvent(WebViewEvent.OnPropertyChange, json.ToString());
        }

        private void Load(string url, string allowingReadAccessTo = null) {
            if (allowingReadAccessTo != null) {
                var fName = Path.GetFileName(url);
                if (fName == null) return;
                var relativeUrl = new Uri(fName, UriKind.Relative);
                var resolver = new StreamResolver(allowingReadAccessTo);
                try {
                    CurrentBrowser.NavigateToLocalStreamUri(relativeUrl, resolver);
                }
                catch (Exception e) {
                    Context.DispatchEvent("TRACE", e.Message);
                }
            }
            else {
                try {
                    CurrentBrowser.Navigate(new Uri(url));
                }
                catch (Exception e) {
                    Context.DispatchEvent("TRACE", e.Message);
                }
            }
        }

        public void Load(UrlRequest url, string allowingReadAccessTo = null) {
            Load(url.Url, allowingReadAccessTo);
        }

        public void LoadHtmlString(string html, UrlRequest url) {
            CurrentBrowser.NavigateToString(html);
        }

        public void ZoomIn() {
            Context.DispatchEvent("TRACE", "ZoomIn Unavailable in Edge");
        }

        public void ZoomOut() {
            Context.DispatchEvent("TRACE", "ZoomOut Unavailable in Edge");
        }

        public void ForceFocus() {
            CurrentBrowser.Focus();
        }

        public void Reload(bool ignoreCache = false) {
            CurrentBrowser.Refresh();
        }

        public void Stop() {
            CurrentBrowser.Stop();
        }

        public void Back() {
            if (CurrentBrowser.CanGoBack) {
                CurrentBrowser.GoBack();
            }
        }

        public void Forward() {
            if (CurrentBrowser.CanGoForward) {
                CurrentBrowser.GoForward();
            }
        }

        public void Print() {
            Context.DispatchEvent("TRACE", "Print Unavailable in Edge");
        }

        public void PrintToPdfAsync(string path) {
            Context.DispatchEvent("TRACE", "PrintToPdfAsync Unavailable in Edge");
        }

        public void AddEventListener(string type) {
            Context.DispatchEvent("TRACE", "AddEventListener Unavailable in Edge");
        }

        public void RemoveEventListener(string type) {
            Context.DispatchEvent("TRACE", "RemoveEventListener Unavailable in Edge");
        }

        public void ShowDevTools() {
            Context.DispatchEvent("TRACE", "ShowDevTools Unavailable in Edge");
        }

        public void CloseDevTools() {
            Context.DispatchEvent("TRACE", "CloseDevTools Unavailable in Edge");
        }

        public async void EvaluateJavaScript(string javascript, string callback) {
            var task = CurrentBrowser.InvokeScriptAsync("eval", javascript);
            await task.ContinueWith(previous => {
                JObject json;
                if (previous.Status == TaskStatus.RanToCompletion) {
                    json = JObject.FromObject(new {
                        message = (string) null,
                        error = (string) null,
                        result = (object) previous.Result,
                        success = true,
                        callbackName = callback
                    });
                    Context.DispatchEvent(WebViewEvent.AsCallbackEvent, json.ToString());
                }
                else {
                    json = JObject.FromObject(new {
                        message = (string) null,
                        error = previous.Exception?.Message,
                        result = (object) null,
                        success = false,
                        callbackName = callback
                    });
                    Context.DispatchEvent(WebViewEvent.AsCallbackEvent, json.ToString());
                }
            }, TaskContinuationOptions.ExecuteSynchronously);
        }

        public void EvaluateJavaScript(string javascript) {
            CurrentBrowser.InvokeScript("eval", javascript);
        }

        public void DeleteCookies() {
            Context.DispatchEvent("TRACE", "DeleteCookies Unavailable in Edge");
        }

        private bool IsWhiteListBlocked(string url) {
            return WhiteList != null && WhiteList.Count != 0 &&
                   !WhiteList.Cast<string>().Any(s => url.ToLower().Contains(s.ToLower()));
        }

        private bool IsBlackListBlocked(string url) {
            return BlackList != null && BlackList.Count != 0 &&
                   BlackList.Cast<string>().Any(s => url.ToLower().Contains(s.ToLower()));
        }
    }
}