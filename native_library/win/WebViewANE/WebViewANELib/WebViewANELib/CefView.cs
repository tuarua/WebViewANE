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
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Forms;
using System.Windows.Forms.Integration;
using CefSharp;
using CefSharp.WinForms;
using Newtonsoft.Json.Linq;
using TuaRua.FreSharp;
using WebViewANELib.CefSharp;

namespace WebViewANELib {
    public partial class CefView : IWebView {
        private WindowsFormsHost _host;
        public string InitialUrl { private get; set; }
        public int X { get; set; }
        public int Y { get; set; }
        public int ViewWidth { get; set; }
        public int ViewHeight { get; set; }
        public int RemoteDebuggingPort { private get; set; }
        public string DownloadPath { private get; set; }
        public string CachePath { private get; set; }
        public bool CacheEnabled { private get; set; }
        public int LogLevel { private get; set; }
        public string BrowserSubprocessPath { private get; set; }
        public bool EnableDownloads { private get; set; }
        public string InjectCode { private get; set; }
        public string InjectScriptUrl { private get; set; }
        public int InjectStartLine { private get; set; }
        public PopupBehaviour PopupBehaviour { private get; set; }
        public Tuple<int, int> PopupDimensions { private get; set; }
        public string UserAgent { private get; set; }
        public string UserDataPath { private get; set; }
        public Dictionary<string, string> CommandLineArgs { private get; set; }
        public ArrayList WhiteList { private get; set; }
        public ArrayList BlackList { private get; set; }
        public bool ContextMenuEnabled { private get; set; }
        public ChromiumWebBrowser CurrentBrowser { get; private set; }

        private readonly ArrayList _tabs = new ArrayList();
        public ArrayList TabDetails { get; } = new ArrayList();

        private bool _isLoaded;
        private string _initialHtml;
        public int CurrentTab { get; private set; }
        public KeyboardHandler KeyboardHandler;

        public static FreContextSharp Context;
        private const double ZoomIncrement = 0.10;

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
                UserAgent = UserAgent,
                UserDataPath = UserDataPath
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

            browser.JavascriptObjectRepository.Register("webViewANE", new BoundObject(Context), true,
                BindingOptions.DefaultBinder);

            // ReSharper disable once UseObjectOrCollectionInitializer
            var dh = new DownloadHandler(DownloadPath);
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

            if (!ContextMenuEnabled) {
                browser.MenuHandler = new MenuHandler();
            }

            // ReSharper disable once UseObjectOrCollectionInitializer
            var rh = new RequestHandler(WhiteList, BlackList);
            rh.OnUrlBlockedFired += OnUrlBlockedFired;

            browser.RequestHandler = rh;

            _tabs.Add(browser);
            TabDetails.Add(new TabDetails());

            return browser;
        }

        private void OnPopupBlock(object sender, string url) {
            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            var json = JObject.FromObject(new {url, tab });
            Context.SendEvent(WebViewEvent.OnPopupBlocked, json.ToString());
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


        private void OnUrlBlockedFired(object sender, string url) {
            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            var json = JObject.FromObject(new {url, tab });
            Context.SendEvent(WebViewEvent.OnUrlBlocked, json.ToString());
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
            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            Context.SendEvent(WebViewEvent.OnFail, e.ToJsonString(tab));
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
            var json = JObject.FromObject(new {propName, value, tab});
            Context.SendEvent(WebViewEvent.OnPropertyChange, json.ToString());
        }


        private static void SendPropertyChange(string propName, string value, int tab) {
            var json = JObject.FromObject(new { propName, value, tab });
            Context.SendEvent(WebViewEvent.OnPropertyChange, json.ToString());
        }

        private static void OnDownloadUpdatedFired(object sender, DownloadItem downloadItem) {
            if (downloadItem.IsCancelled) {
                Context.SendEvent(WebViewEvent.OnDownloadCancel, downloadItem.Id.ToString());
                return;
            }

            if (downloadItem.IsComplete) {
                Context.SendEvent(WebViewEvent.OnDownloadComplete, downloadItem.Id.ToString());
                return;
            }

            Context.SendEvent(WebViewEvent.OnDownloadProgress, downloadItem.ToJsonString());
        }

        private static void OnDownloadFired(object sender, DownloadItem downloadItem) { }

        private static void OnKeyEventFired(object sender, int e) {
            Context.SendEvent(WebViewEvent.OnEscKey, e.ToString());
        }

        public void ZoomIn() {
            var task = CurrentBrowser.GetZoomLevelAsync();
            task.ContinueWith(previous => {
                if (previous.Status == TaskStatus.RanToCompletion) {
                    var currentLevel = previous.Result;
                    CurrentBrowser.SetZoomLevel(currentLevel + ZoomIncrement);
                }
                else {
                    throw new InvalidOperationException("Unexpected failure of calling CEF->GetZoomLevelAsync",
                        previous.Exception);
                }
            }, TaskContinuationOptions.ExecuteSynchronously);
        }

        public void ZoomOut() {
            var task = CurrentBrowser.GetZoomLevelAsync();
            task.ContinueWith(previous => {
                if (previous.Status == TaskStatus.RanToCompletion) {
                    var currentLevel = previous.Result;
                    CurrentBrowser.SetZoomLevel(currentLevel - ZoomIncrement);
                }
                else {
                    throw new InvalidOperationException("Unexpected failure of calling CEF->GetZoomLevelAsync",
                        previous.Exception);
                }
            }, TaskContinuationOptions.ExecuteSynchronously);
        }

        public void ForceFocus() {
            CurrentBrowser.Focus();
        }

        public void Reload(bool ignoreCache) {
            CurrentBrowser.Reload(ignoreCache);
        }

        public void Stop() {
            CurrentBrowser.Stop();
        }

        public void Back() {
            if (CurrentBrowser.CanGoBack) {
                CurrentBrowser.Back();
            }
        }

        public void Forward() {
            if (CurrentBrowser.CanGoForward) {
                CurrentBrowser.Forward();
            }
        }

        public void Print() {
            CurrentBrowser.Print();
        }

        public void PrintToPdfAsync(string path) {
            var printToPdf = CurrentBrowser.PrintToPdfAsync(path);
            printToPdf.ContinueWith(_ => { Context.SendEvent(WebViewEvent.OnPdfPrinted, ""); },
                TaskContinuationOptions.OnlyOnRanToCompletion);
        }

        public void AddEventListener(string type) {
            // ReSharper disable once ConvertIfStatementToSwitchStatement
            if (type == "keyUp") {
                KeyboardHandler.HasKeyUp = true;
            }
            else if (type == "keyDown") {
                KeyboardHandler.HasKeyDown = true;
            }
        }

        public void RemoveEventListener(string type) {
            // ReSharper disable once ConvertIfStatementToSwitchStatement
            if (type == "keyUp")
                KeyboardHandler.HasKeyUp = false;
            else if (type == "keyDown") {
                KeyboardHandler.HasKeyDown = false;
            }
        }

        public void ShowDevTools() {
            CurrentBrowser.ShowDevTools();
        }

        public void CloseDevTools() {
            CurrentBrowser.CloseDevTools();
        }


        public async void EvaluateJavaScript(string javascript, string callback) {
            try {
                var mf = CurrentBrowser.GetMainFrame();
                var response =
                    await mf.EvaluateScriptAsync(javascript, TimeSpan.FromMilliseconds(500).ToString());
                if (response.Success && response.Result is IJavascriptCallback) {
                    response = await ((IJavascriptCallback) response.Result).ExecuteAsync("");
                }

                Context.SendEvent(WebViewEvent.AsCallbackEvent, response.ToJsonString(callback));
            }
            catch (Exception e) {
                Context.SendEvent(WebViewEvent.AsCallbackEvent, e.ToJsonString(callback));
            }
        }

        public void EvaluateJavaScript(string javascript) {
            try {
                var mf = CurrentBrowser.GetMainFrame();
                mf.ExecuteJavaScriptAsync(javascript); // this is fire and forget can run js urls, startLine 
            }
            catch (Exception e) {
                Console.WriteLine(@"JS error: " + e.Message);
            }
        }

        private static void CefView_Loaded(object sender, RoutedEventArgs e) { }
    }
}