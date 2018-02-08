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
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Forms.Integration;
using CefSharp;
using CefSharp.WinForms;
using Newtonsoft.Json;
using TuaRua.FreSharp;

namespace CefSharpLib {
    public partial class CefView {
        private WindowsFormsHost _host;
        public string InitialUrl { get; set; }
        public int X { get; set; }
        public int Y { get; set; }
        public int ViewWidth { get; set; }
        public int ViewHeight { get; set; }
        public int RemoteDebuggingPort { get; set; }
        public string CachePath { get; set; }
        public bool CacheEnabled { get; set; }
        public int LogLevel { get; set; }
        public string BrowserSubprocessPath { get; set; }
        public bool EnableDownloads { get; set; }

        public string InjectCode { get; set; }
        public string InjectScriptUrl { get; set; }
        public int InjectStartLine { get; set; }
        public PopupBehaviour PopupBehaviour { get; set; }
        public Tuple<int, int> PopupDimensions { get; set; }
        public string UserAgent { get; set; }
        public Dictionary<string, string> CommandLineArgs { get; set; }
        public ArrayList WhiteList { get; set; }
        public ArrayList BlackList { get; set; }
        public bool ContextMenuEnabled { get; set; }

        public ChromiumWebBrowser CurrentBrowser;

        private readonly ArrayList _tabs = new ArrayList();
        public ArrayList TabDetails { get; } = new ArrayList();

        private bool _isLoaded;
        private string _initialHtml;
        public int CurrentTab { get; set; }

        public const string AsCallbackEvent = "TRWV.as.CALLBACK";
        private const string OnDownloadProgress = "WebView.OnDownloadProgress";
        private const string OnDownloadComplete = "WebView.OnDownloadComplete";
        private const string OnDownloadCancel = "WebView.OnDownloadCancel";
        private const string OnPropertyChange = "WebView.OnPropertyChange";
        private const string OnEscKey = "WebView.OnEscKey";
        private const string OnFail = "WebView.OnFail";
        private const string OnPermission = "WebView.OnPermissionResult";
        private const string OnUrlBlocked = "WebView.OnUrlBlocked";
        private const string OnPopupBlocked = "WebView.OnPopupBlocked";
        public const string OnPdfPrinted = "WebView.OnPdfPrinted";
        public KeyboardHandler KeyboardHandler;
        public static FreContextSharp Context;

        public void Init() {
            InitializeComponent();
            IsManipulationEnabled = true;
            // ReSharper disable once UseObjectOrCollectionInitializer
            _host = new WindowsFormsHost();
            _host.IsManipulationEnabled = true;

            Loaded += CefView_Loaded;
            var settings = new CefSettings {
                RemoteDebuggingPort = RemoteDebuggingPort,
                CachePath = CacheEnabled ? CachePath : "",
                UserAgent = UserAgent
            };

            CefSharpSettings.ShutdownOnExit = false;
        
            switch (LogLevel) {
                case 0:
                    settings.LogSeverity = LogSeverity.Default;
                    break;
                case 1:
                    settings.LogSeverity = LogSeverity.Verbose;
                    break;
                case 2:
                    settings.LogSeverity = LogSeverity.Info;
                    break;
                case 3:
                    settings.LogSeverity = LogSeverity.Warning;
                    break;
                case 4:
                    settings.LogSeverity = LogSeverity.Error;
                    break;
                case 99:
                    settings.LogSeverity = LogSeverity.Disable;
                    break;
                default:
                    settings.LogSeverity = LogSeverity.Disable;
                    break;
            }
            settings.WindowlessRenderingEnabled = false;
            settings.BrowserSubprocessPath = BrowserSubprocessPath;

            foreach (var kvp in CommandLineArgs) {
                settings.CefCommandLineArgs.Add(kvp.Key, kvp.Value);
            }


            Cef.EnableHighDPISupport();
            // ReSharper disable once InvertIf
            if (Cef.Initialize(settings)) {
                var browser = CreateNewBrowser();

                CurrentBrowser = browser;
                _host.Child = browser;
                MainGrid.Children.Add(_host);
            }
        }

        private ChromiumWebBrowser CreateNewBrowser() {
            // ReSharper disable once UseObjectOrCollectionInitializer
            var browser = new ChromiumWebBrowser(InitialUrl) {
                Dock = DockStyle.Fill
            };
        
            browser.JavascriptObjectRepository.Register("webViewANE", new BoundObject(Context), true, BindingOptions.DefaultBinder);

            // ReSharper disable once UseObjectOrCollectionInitializer
            var dh = new DownloadHandler();
            dh.OnDownloadUpdatedFired += OnDownloadUpdatedFired;
            dh.OnBeforeDownloadFired += OnDownloadFired;

            // ReSharper disable once UseObjectOrCollectionInitializer
            KeyboardHandler = new KeyboardHandler(Context);
            KeyboardHandler.OnKeyEventFired += OnKeyEventFired;

            if (EnableDownloads) {
                browser.DownloadHandler = dh;
            }
            browser.KeyboardHandler = KeyboardHandler;

            // ReSharper disable once UseObjectOrCollectionInitializer
            var gh = new GeolocationHandler();
            gh.OnPermissionResult += OnPermissionResult;
            browser.GeolocationHandler = gh;


            // ReSharper disable once UseObjectOrCollectionInitializer
            var sh = new LifeSpanHandler(PopupBehaviour, PopupDimensions);
            sh.OnPermissionPopup += OnPermissionPopup;
            sh.OnPopupBlock += OnPopupBlock;
            browser.LifeSpanHandler = sh;
            browser.FrameLoadEnd += OnFrameLoaded;
            browser.AddressChanged += OnBrowserAddressChanged;
            browser.TitleChanged += OnBrowserTitleChanged;
            browser.LoadingStateChanged += OnBrowserLoadingStateChanged;
            browser.LoadError += OnLoadError;
            browser.IsBrowserInitializedChanged += OnBrowserInitialized;
            browser.StatusMessage += OnStatusMessage;
            browser.DisplayHandler = new DisplayHandler();

            if (!ContextMenuEnabled)
                browser.MenuHandler = new MenuHandler();

            // ReSharper disable once UseObjectOrCollectionInitializer
            var rh = new RequestHandler(WhiteList, BlackList);
            rh.OnUrlBlockedFired += OnUrlBlockedFired;

            browser.RequestHandler = rh;

            _tabs.Add(browser);
            TabDetails.Add(new TabDetails());

            return browser;
        }

        private void OnPopupBlock(object sender, string e) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;

            writer.WriteStartObject();
            writer.WritePropertyName("url");
            writer.WriteValue(e);
            writer.WritePropertyName("tab");
            writer.WriteValue(tab);
            writer.WriteEndObject();

            Context.SendEvent(OnPopupBlocked, sb.ToString());
        }

        public void AddTab() {
            CurrentTab = _tabs.Count;
            CurrentBrowser = CreateNewBrowser();
            _host.Child = CurrentBrowser;

        }

        public void SetCurrentTab(int index) {
            if (index < 0 || index > _tabs.Count - 1) return;
            CurrentTab = index;
            CurrentBrowser = _tabs[CurrentTab] as ChromiumWebBrowser;
            _host.Child = CurrentBrowser;

            if (!(TabDetails[CurrentTab] is TabDetails tabDetails)) return;
            SendPropertyChange(@"title", tabDetails.Title, CurrentTab);
            SendPropertyChange(@"url", tabDetails.Address, CurrentTab);
            SendPropertyChange(@"isLoading", tabDetails.IsLoading, CurrentTab);
            SendPropertyChange(@"canGoForward", tabDetails.CanGoForward, CurrentTab);
            SendPropertyChange(@"canGoBack", tabDetails.CanGoBack, CurrentTab);
        }

        public void CloseTab(int index) {
            if (index < 0 || index > _tabs.Count - 1) {
                return;
            }

            if (CurrentTab >= index) {
                CurrentTab = CurrentTab - 1;
            }
            if (_tabs.Count == 2) {
                CurrentTab = 0;
            }
            if (CurrentTab < 0) {
                CurrentTab = 0;
            }
            var wvtc = _tabs[index] as ChromiumWebBrowser;
            _tabs.RemoveAt(index);
            TabDetails.RemoveAt(index);
            wvtc?.Dispose();

            CurrentBrowser = _tabs[CurrentTab] as ChromiumWebBrowser;
            _host.Child = CurrentBrowser;

            if (!(TabDetails[CurrentTab] is TabDetails tabDetails)) return;
            SendPropertyChange(@"title", tabDetails.Title, CurrentTab);
            SendPropertyChange(@"url", tabDetails.Address, CurrentTab);
            SendPropertyChange(@"isLoading", tabDetails.IsLoading, CurrentTab);
            SendPropertyChange(@"canGoForward", tabDetails.CanGoForward, CurrentTab);
            SendPropertyChange(@"canGoBack", tabDetails.CanGoBack, CurrentTab);
        }


        private void OnUrlBlockedFired(object sender, string e) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;

            writer.WriteStartObject();
            writer.WritePropertyName("url");
            writer.WriteValue(e);
            writer.WritePropertyName("tab");
            writer.WriteValue(tab);
            writer.WriteEndObject();

            Context.SendEvent(OnUrlBlocked, sb.ToString());
        }

        private void OnPermissionPopup(object sender, string s) {
            Load(s);
        }

        private void OnFrameLoaded(object sender, FrameLoadEndEventArgs e) {
            if (!e.Frame.IsMain) return;
            if (!string.IsNullOrEmpty(InjectCode) || !string.IsNullOrEmpty(InjectScriptUrl)) {
                e.Frame.ExecuteJavaScriptAsync(InjectCode, InjectScriptUrl, InjectStartLine);
            }
        }

        private TabDetails GetTabDetails(int tab) {
            return (TabDetails) TabDetails[tab];
        }

        private void OnBrowserAddressChanged(object sender, AddressChangedEventArgs e) {
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(sender)) continue;
                var tabDetails = GetTabDetails(index);
                if (tabDetails.Address == e.Address) {
                    return;
                }
                tabDetails.Address = e.Address;
                SendPropertyChange(@"url", e.Address, index);
            }
        }

        private void OnBrowserTitleChanged(object sender, TitleChangedEventArgs e) {
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(sender)) continue;
                var tabDetails = GetTabDetails(index);
                if (tabDetails.Title == e.Title) {
                    return;
                }
                tabDetails.Title = e.Title;
                SendPropertyChange(@"title", e.Title, index);
            }
        }

        private void OnBrowserLoadingStateChanged(object sender, LoadingStateChangedEventArgs e) {
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(sender)) continue;
                var tabDetails = GetTabDetails(index);
                if (tabDetails.IsLoading == e.IsLoading) {
                    return;
                }
                tabDetails.IsLoading = e.IsLoading;
                SendPropertyChange(@"isLoading", e.IsLoading, index);
                if (!e.IsLoading) {
                    CurrentBrowser.Focus();
                }

                if (tabDetails.CanGoForward != e.CanGoForward) {
                    tabDetails.CanGoForward = e.CanGoForward;
                    SendPropertyChange(@"canGoForward", e.CanGoForward, index);
                }

                if (tabDetails.CanGoBack == e.CanGoBack) {
                    return;
                }

                tabDetails.CanGoBack = e.CanGoBack;
                SendPropertyChange(@"canGoBack", e.CanGoBack, index);
            }
        }

        private void OnLoadError(object sender, LoadErrorEventArgs e) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;

            writer.WriteStartObject();
            writer.WritePropertyName("url");
            writer.WriteValue(e.FailedUrl);
            writer.WritePropertyName("errorCode");
            writer.WriteValue(e.ErrorCode);
            writer.WritePropertyName("errorText");
            writer.WriteValue(e.ErrorText);
            writer.WritePropertyName("tab");
            writer.WriteValue(tab);
            writer.WriteEndObject();
            Context.SendEvent(OnFail, sb.ToString());
        }

        private void OnBrowserInitialized(object sender, IsBrowserInitializedChangedEventArgs e) {
            _isLoaded = e.IsBrowserInitialized;
            if (!_isLoaded) return;
            if (!string.IsNullOrEmpty(CurrentBrowser.Address)) return;
            if (!string.IsNullOrEmpty(_initialHtml)) {
                LoadHtmlString(_initialHtml, InitialUrl);
            }
            else if (!string.IsNullOrEmpty(InitialUrl)) {
                Load(InitialUrl);
            }
        }

        public void Load(string url) {
            if (_isLoaded) {
                CurrentBrowser.Load(Encoding.UTF8.GetString(Encoding.Default.GetBytes(url)));
            }
            else {
                InitialUrl = url;
            }
        }

        public void LoadHtmlString(string html, string url) {
            if (_isLoaded) {
                CurrentBrowser.LoadHtml(Encoding.UTF8.GetString(Encoding.Default.GetBytes(html)), Encoding.UTF8.GetString(Encoding.Default.GetBytes(url)));
            }
            else {
                _initialHtml = html;
                InitialUrl = url;
            }
        }

        private void OnStatusMessage(object sender, StatusMessageEventArgs e) {
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(sender)) continue;
                var tabDetails = GetTabDetails(index);
                if (tabDetails.StatusMessage == e.Value) {
                    return;
                }
                tabDetails.StatusMessage = e.Value;
                SendPropertyChange(@"statusMessage", e.Value, index);
            }
        }

        private static void SendPropertyChange(string propName, bool value, int tab) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            writer.WriteStartObject();
            writer.WritePropertyName("propName");
            writer.WriteValue(propName);
            writer.WritePropertyName("value");
            writer.WriteValue(value);
            writer.WritePropertyName("tab");
            writer.WriteValue(tab);
            writer.WriteEndObject();
            Context.SendEvent(OnPropertyChange, sb.ToString());
        }


        private static void SendPropertyChange(string propName, string value, int tab) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            writer.WriteStartObject();
            writer.WritePropertyName("propName");
            writer.WriteValue(propName);
            writer.WritePropertyName("value");
            writer.WriteValue(value);
            writer.WritePropertyName("tab");
            writer.WriteValue(tab);
            writer.WriteEndObject();
            Context.SendEvent(OnPropertyChange, sb.ToString());
        }

        private static void OnDownloadUpdatedFired(object sender, DownloadItem downloadItem) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            if (downloadItem.IsCancelled) {
                Context.SendEvent(OnDownloadCancel, downloadItem.Id.ToString());
                return;
            }

            if (downloadItem.IsComplete) {
                Context.SendEvent(OnDownloadComplete, downloadItem.Id.ToString());
                return;
            }
            writer.WriteStartObject();

            writer.WritePropertyName("id");
            writer.WriteValue(downloadItem.Id);

            writer.WritePropertyName("url");
            writer.WriteValue(downloadItem.OriginalUrl);

            writer.WritePropertyName("speed");
            writer.WriteValue(downloadItem.CurrentSpeed);

            writer.WritePropertyName("percent");
            writer.WriteValue(downloadItem.PercentComplete);

            writer.WritePropertyName("bytesLoaded");
            writer.WriteValue(downloadItem.ReceivedBytes);

            writer.WritePropertyName("bytesTotal");
            writer.WriteValue(downloadItem.TotalBytes);

            writer.WriteEndObject();
            Context.SendEvent(OnDownloadProgress, sb.ToString());
        }

        private static void OnDownloadFired(object sender, DownloadItem downloadItem) { }

        private static void OnKeyEventFired(object sender, int e) {
            Context.SendEvent(OnEscKey, e.ToString());
        }

        private static void OnPermissionResult(object sender, bool e) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            writer.WriteStartObject();
            writer.WritePropertyName("type");
            writer.WriteValue("geolocation");
            writer.WritePropertyName("result");
            writer.WriteValue(e);
            writer.WriteEndObject();
            Context.SendEvent(OnPermission, sb.ToString());
        }

        private static void CefView_Loaded(object sender, RoutedEventArgs e) { }
    }
}