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
        public bool ContextMenuEnabled { get; set; }

        public ChromiumWebBrowser CurrentBrowser;
        private readonly ArrayList _browserTabs = new ArrayList();
        private readonly Dictionary<int, TabDetails> _browserTabDetails = new Dictionary<int, TabDetails>();
        private bool _isLoaded;
        private string _initialHtml;
        private string _address;
        private string _title;
        private bool _isLoading;
        private bool _canGoBack;
        private bool _canGoForward;
        private int _currentTab;

        public const string AsCallbackEvent = "TRWV.as.CALLBACK";
        private const string OnDownloadProgress = "WebView.OnDownloadProgress";
        private const string OnDownloadComplete = "WebView.OnDownloadComplete";
        private const string OnDownloadCancel = "WebView.OnDownloadCancel";
        private const string OnPropertyChange = "WebView.OnPropertyChange";
        private const string OnEscKey = "WebView.OnEscKey";
        private const string OnFail = "WebView.OnFail";
        private const string OnPermission = "WebView.OnPermissionResult";
        private const string OnUrlBlocked = "WebView.OnUrlBlocked";

        public void Init() {
            InitializeComponent();
            IsManipulationEnabled = true;
            // ReSharper disable once UseObjectOrCollectionInitializer
            _host = new WindowsFormsHost();
            _host.IsManipulationEnabled = true;

            Loaded += CefView_Loaded;
            var settings = new CefSettings {
                RemoteDebuggingPort = RemoteDebuggingPort,
                CachePath = CachePath,
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
            Console.WriteLine(@"CreateNewBrowser called");
            // ReSharper disable once UseObjectOrCollectionInitializer
            var browser = new ChromiumWebBrowser(InitialUrl) {
                Dock = DockStyle.Fill
            };

            browser.RegisterAsyncJsObject("webViewANE", new BoundObject(), BindingOptions.DefaultBinder);

            // ReSharper disable once UseObjectOrCollectionInitializer
            var dh = new DownloadHandler();
            dh.OnDownloadUpdatedFired += OnDownloadUpdatedFired;
            dh.OnBeforeDownloadFired += OnDownloadFired;

            // ReSharper disable once UseObjectOrCollectionInitializer
            var kh = new KeyboardHandler();
            kh.OnKeyEventFired += OnKeyEventFired;

            if (EnableDownloads)
                browser.DownloadHandler = dh;
            browser.KeyboardHandler = kh;

            // ReSharper disable once UseObjectOrCollectionInitializer
            var gh = new GeolocationHandler();
            gh.OnPermissionResult += OnPermissionResult;
            browser.GeolocationHandler = gh;


            // ReSharper disable once UseObjectOrCollectionInitializer
            var sh = new LifeSpanHandler(PopupBehaviour, PopupDimensions);
            sh.OnPermissionPopup += OnPermissionPopup;

            browser.LifeSpanHandler = sh;
            browser.FrameLoadEnd += OnFrameLoaded;
            browser.AddressChanged += OnBrowserAddressChanged;
            browser.TitleChanged += OnBrowserTitleChanged;
            browser.LoadingStateChanged += OnBrowserLoadingStateChanged;
            browser.LoadError += OnLoadError;
            browser.IsBrowserInitializedChanged += OnBrowserInitialized;
            browser.StatusMessage += OnStatusMessage;

            if (!ContextMenuEnabled)
                browser.MenuHandler = new MenuHandler();

            // ReSharper disable once UseObjectOrCollectionInitializer
            var rh = new RequestHandler(WhiteList);
            rh.OnUrlBlockedFired += OnUrlBlockedFired;

            browser.RequestHandler = rh;

            _browserTabs.Add(browser);
            return browser;
        }

        public int AddTab() {
            _currentTab = _browserTabs.Count;
            _host.Child = CreateNewBrowser();
            return _currentTab;
        }

        public int SwitchTab(int index) {
            if (index < 0 || index > _browserTabs.Count - 1) return -1;

            _currentTab = index;
            var browser = _browserTabs[_currentTab] as ChromiumWebBrowser;
            _host.Child = browser;

            SendPropertyChange(@"title", _browserTabDetails[_currentTab].Title, _currentTab);
            SendPropertyChange(@"url", _browserTabDetails[_currentTab].Address, _currentTab);
            SendPropertyChange(@"isLoading", _browserTabDetails[_currentTab].IsLoading, _currentTab);
            SendPropertyChange(@"canGoForward", _browserTabDetails[_currentTab].CanGoForward, _currentTab);
            SendPropertyChange(@"canGoBack", _browserTabDetails[_currentTab].CanGoBack, _currentTab);
            return _currentTab;
        }

        private void OnUrlBlockedFired(object sender, string e) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            var tab = _browserTabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;

            writer.WriteStartObject();
            writer.WritePropertyName("url");
            writer.WriteValue(e);
            writer.WritePropertyName("tab");
            writer.WriteValue(tab);
            writer.WriteEndObject();

            FreSharpController.Context.DispatchEvent(OnUrlBlocked, sb.ToString());
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

        private void OnBrowserAddressChanged(object sender, AddressChangedEventArgs e) {
            if (_address == e.Address) return;
            _address = e.Address;

            var tab = _browserTabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            var tabDetails = GetTabDetails(tab);
            tabDetails.Address = _address;

            SendPropertyChange(@"url", _address, tab);
        }

        private void OnBrowserTitleChanged(object sender, TitleChangedEventArgs e) {
            if (_title == e.Title) return;
            _title = e.Title;

            var tab = _browserTabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            var tabDetails = GetTabDetails(tab);
            tabDetails.Title = _title;

            SendPropertyChange(@"title", _title, tab);
        }

        private TabDetails GetTabDetails(int tab) {
            if (!_browserTabDetails.ContainsKey(tab)) {
                _browserTabDetails[tab] = new TabDetails();
            }
            return _browserTabDetails[tab];
        }

        private void OnBrowserLoadingStateChanged(object sender, LoadingStateChangedEventArgs e) {
            if (_isLoading == e.IsLoading) return;
            _isLoading = e.IsLoading;
            var tab = _browserTabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            var tabDetails = GetTabDetails(tab);
            tabDetails.IsLoading = _isLoading;

            SendPropertyChange(@"isLoading", _isLoading, tab);

            if (!_isLoading) {
                CurrentBrowser.Focus();
            }

            if (_canGoForward != e.CanGoForward) {
                _canGoForward = e.CanGoForward;
                SendPropertyChange(@"canGoForward", _canGoForward, tab);
            }

            if (_canGoBack == e.CanGoBack) return;
            _canGoBack = e.CanGoBack;
            SendPropertyChange(@"canGoBack", _canGoBack, tab);
        }

        private  void OnLoadError(object sender, LoadErrorEventArgs e) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            var tab = _browserTabs.IndexOf(sender);
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
            FreSharpController.Context.DispatchEvent(OnFail, sb.ToString());
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
                CurrentBrowser.Load(url);
            }
            else {
                InitialUrl = url;
            }
        }

        public void LoadHtmlString(string html, string url) {
            if (_isLoaded) {
                CurrentBrowser.LoadHtml(html, url);
            }
            else {
                _initialHtml = html;
                InitialUrl = url;
            }
        }

        private void OnStatusMessage(object sender, StatusMessageEventArgs e) {
            var tab = _browserTabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            var tabDetails = GetTabDetails(tab);
            tabDetails.StatusMessage = e.Value;
            SendPropertyChange(@"statusMessage", e.Value, tab);
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
            FreSharpController.Context.DispatchEvent(OnPropertyChange, sb.ToString());
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
            FreSharpController.Context.DispatchEvent(OnPropertyChange, sb.ToString());
        }

        private static void OnDownloadUpdatedFired(object sender, DownloadItem downloadItem) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            if (downloadItem.IsCancelled) {
                FreSharpController.Context.DispatchEvent(OnDownloadCancel, downloadItem.Id.ToString());
                return;
            }

            if (downloadItem.IsComplete) {
                FreSharpController.Context.DispatchEvent(OnDownloadComplete, downloadItem.Id.ToString());
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
            FreSharpController.Context.DispatchEvent(OnDownloadProgress, sb.ToString());
        }

        private static void OnDownloadFired(object sender, DownloadItem downloadItem) { }

        private static void OnKeyEventFired(object sender, int e) {
            FreSharpController.Context.DispatchEvent(OnEscKey, e.ToString());
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
            FreSharpController.Context.DispatchEvent(OnPermission, sb.ToString());
        }

        private static void CefView_Loaded(object sender, RoutedEventArgs e) { }
    }
}