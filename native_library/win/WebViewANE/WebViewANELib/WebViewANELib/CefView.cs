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
using System.IO;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Forms;
using CefSharp;
using CefSharp.WinForms;
using Newtonsoft.Json.Linq;
using TuaRua.FreSharp;
using WebViewANELib.CefSharp;

// ReSharper disable ConvertIfStatementToSwitchStatement
// ReSharper disable UseObjectOrCollectionInitializer
// ReSharper disable InvertIf

namespace WebViewANELib {
    public partial class CefView : IWebView {
        private CefWindowsFormsHost _host;
        public UrlRequest InitialUrl { private get; set; }
        public int X { get; set; }
        public int Y { get; set; }
        public int ViewWidth { get; set; }
        public int ViewHeight { get; set; }
        public int RemoteDebuggingPort { private get; set; }
        public bool EnablePrintPreview { private get; set; }
        public bool DisableFileDialog { private get; set; }
        public string DownloadPath { private get; set; }
        public string CachePath { private get; set; }
        public bool CacheEnabled { private get; set; }
        public int LogLevel { private get; set; }
        public string AcceptLanguageList { private get; set; }
        public string Locale { private get; set; }
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
        private ChromiumWebBrowser CurrentBrowser { get; set; }

        private readonly ArrayList _tabs = new ArrayList();
        public ArrayList TabDetails { get; } = new ArrayList();

        private bool _isLoaded;
        private string _initialHtml;
        public int CurrentTab { get; private set; }
        private LifeSpanHandler lifeSpanHandler;
        private double _scaleFactor;
        public double ScaleFactor {
            set {
                if (lifeSpanHandler != null) {
                    lifeSpanHandler.ScaleFactor = value;
                }
                _scaleFactor = value;
            }
        }
        private KeyboardHandler KeyboardHandler;
        public static FreContextSharp Context;
        private const double ZoomIncrement = 0.10;

        public void Init() {
            InitializeComponent();
            IsManipulationEnabled = true;
            _host = new CefWindowsFormsHost();
            _host.IsManipulationEnabled = true;

            Loaded += CefView_Loaded;
            var settings = new CefSettings {
                RemoteDebuggingPort = RemoteDebuggingPort,
                CachePath = CacheEnabled ? CachePath : "",
                UserAgent = UserAgent,
                UserDataPath = UserDataPath
            };
            if (EnablePrintPreview) {
                settings.EnablePrintPreview();
            }
           
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

            var exeCommandLineArgs = Environment.GetCommandLineArgs();
            var isAdl = false;
            var baseDir = "";

            for (var i = 0; i < exeCommandLineArgs.Length; i++) {
                var item = exeCommandLineArgs[i];
                if (item.Equals("-extdir")) {
                    isAdl = true;
                    baseDir = exeCommandLineArgs[i + 1];
                    break;
                }
            }

            if (!isAdl) {
                var fullPath = Process.GetCurrentProcess().MainModule?.FileName;
                if (!string.IsNullOrEmpty(fullPath)) {
                    baseDir = Path.GetDirectoryName(fullPath) + "\\META-INF\\AIR\\extensions";
                }
            }

            var platform = Environment.Is64BitProcess ? "x86-64" : "x86";
            var directories = Directory.GetDirectories(baseDir);
            var foundCefSharp = false;
            foreach (var dir in directories) {
                var fileName = dir + "\\META-INF\\ANE\\Windows-" + platform + "\\CefSharp.BrowserSubprocess.exe";
                if (File.Exists(fileName)) {
                    settings.BrowserSubprocessPath = fileName;
                    settings.ResourcesDirPath = dir + "\\META-INF\\ANE\\Windows-" + platform;
                    foundCefSharp = true;
                    break;
                }
            }

            if (!foundCefSharp) {
                Context.DispatchEvent("TRACE", "Cannot find the requierd CefSharp.BrowserSubprocess.exe");
                return;
            }
            
            settings.AcceptLanguageList = AcceptLanguageList;
            settings.Locale = Locale;

            foreach (var kvp in CommandLineArgs) {
                settings.CefCommandLineArgs.Add(kvp.Key, kvp.Value);
            }

            Cef.EnableHighDPISupport();
            if (Cef.Initialize(settings, false, (IBrowserProcessHandler) null)) {
                var browser = CreateNewBrowser();
                CurrentBrowser = browser;
                _host.Child = browser;
                MainGrid.Children.Add(_host);
            }
        }

        private ChromiumWebBrowser CreateNewBrowser() {
            var browser = new ChromiumWebBrowser(InitialUrl?.Url) {
                Dock = DockStyle.Fill
            };

            browser.JavascriptObjectRepository.Register("webViewANE", new BoundObject(Context), true,
                BindingOptions.DefaultBinder);

            var dh = new DownloadHandler(DownloadPath);
            dh.OnDownloadUpdatedFired += OnDownloadUpdated;
            dh.OnBeforeDownloadFired += OnBeforeDownload;

            KeyboardHandler = new KeyboardHandler(Context);
            KeyboardHandler.OnKeyEventFired += OnKeyEvent;

            if (EnableDownloads) {
                browser.DownloadHandler = dh;
            }

            browser.KeyboardHandler = KeyboardHandler;

            lifeSpanHandler = new LifeSpanHandler(PopupBehaviour, PopupDimensions, _scaleFactor);
            lifeSpanHandler.OnPermissionPopup += OnPermissionPopup;
            lifeSpanHandler.OnPopupBlock += OnPopupBlock;
            browser.LifeSpanHandler = lifeSpanHandler;
            browser.FrameLoadEnd += OnFrameLoaded;
            browser.AddressChanged += OnBrowserAddressChanged;
            browser.TitleChanged += OnBrowserTitleChanged;
            browser.LoadingStateChanged += OnBrowserLoadingStateChanged;
            browser.LoadError += OnLoadError;
            browser.IsBrowserInitializedChanged += OnBrowserInitialized;
            browser.StatusMessage += OnStatusMessage;
            var displayHandler = new DisplayHandler();
            displayHandler.OnLoadingProgressChangeFired += OnLoadingProgressChange;
            browser.DisplayHandler = displayHandler;

            var dialogHandler = new DialogHandler {
                Disabled = DisableFileDialog
            };
            browser.DialogHandler = dialogHandler;

            if (!ContextMenuEnabled) {
                browser.MenuHandler = new MenuHandler();
            }

            var rh = new CefRequestHandler(WhiteList, BlackList);
            rh.OnUrlBlockedFired += OnUrlBlocked;

            browser.RequestHandler = rh;
            _tabs.Add(browser);
            TabDetails.Add(new TabDetails());

            return browser;
        }

        private void OnLoadingProgressChange(object sender, double progress) {
            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            var json = JObject.FromObject(new {propName = "estimatedProgress", value = progress, tab});
            Context.DispatchEvent(WebViewEvent.OnPropertyChange, json.ToString());
        }

        private void OnPopupBlock(object sender, string url) {
            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            var json = JObject.FromObject(new {url, tab});
            Context.DispatchEvent(WebViewEvent.OnPopupBlocked, json.ToString());
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


        private void OnUrlBlocked(object sender, string url) {
            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            var json = JObject.FromObject(new {url, tab});
            Context.DispatchEvent(WebViewEvent.OnUrlBlocked, json.ToString());
        }

        private void OnPermissionPopup(object sender, string s) {
            CurrentBrowser.Load(s);
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
                if (tabDetails.Address == e.Address) return;

                tabDetails.Address = e.Address;
                SendPropertyChange(@"url", e.Address, index);
            }
        }

        private void OnBrowserTitleChanged(object sender, TitleChangedEventArgs e) {
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(sender)) continue;
                var tabDetails = GetTabDetails(index);
                if (tabDetails.Title == e.Title) return;
                tabDetails.Title = e.Title;
                SendPropertyChange(@"title", e.Title, index);
            }
        }

        private void OnBrowserLoadingStateChanged(object sender, LoadingStateChangedEventArgs e) {
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(sender)) continue;
                var tabDetails = GetTabDetails(index);
                if (tabDetails.IsLoading == e.IsLoading) return;

                tabDetails.IsLoading = e.IsLoading;
                SendPropertyChange(@"isLoading", e.IsLoading, index);
                if (!e.IsLoading) {
                    CurrentBrowser.Focus();
                }

                if (tabDetails.CanGoForward != e.CanGoForward) {
                    tabDetails.CanGoForward = e.CanGoForward;
                    SendPropertyChange(@"canGoForward", e.CanGoForward, index);
                }

                if (tabDetails.CanGoBack == e.CanGoBack) return;

                tabDetails.CanGoBack = e.CanGoBack;
                SendPropertyChange(@"canGoBack", e.CanGoBack, index);
            }
        }

        private void OnLoadError(object sender, LoadErrorEventArgs e) {
            var tab = _tabs.IndexOf(sender);
            tab = tab == -1 ? 0 : tab;
            Context.DispatchEvent(WebViewEvent.OnFail, e.ToJsonString(tab));
        }

        private void OnBrowserInitialized(object sender, EventArgs e) {
            _isLoaded = true;
            if (!_isLoaded) return;
            if (!string.IsNullOrEmpty(CurrentBrowser.Address)) return;
            if (!string.IsNullOrEmpty(_initialHtml)) {
                LoadHtmlString(_initialHtml, InitialUrl);
            }
            else if (InitialUrl != null && !string.IsNullOrEmpty(InitialUrl.Url)) {
                Load(InitialUrl);
            }
        }

        public void Load(UrlRequest url, string allowingReadAccessTo = null) {
            if (_isLoaded) {
                CurrentBrowser.Load(url.Url);
            }
            else {
                InitialUrl = url;
            }
        }

        public void LoadHtmlString(string html, UrlRequest url) {
            if (_isLoaded) {
                CurrentBrowser.LoadHtml(html, url.Url);
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
                if (tabDetails.StatusMessage == e.Value) return;

                tabDetails.StatusMessage = e.Value;
                SendPropertyChange(@"statusMessage", e.Value, index);
            }
        }

        private static void SendPropertyChange(string propName, bool value, int tab) {
            var json = JObject.FromObject(new {propName, value, tab});
            Context.DispatchEvent(WebViewEvent.OnPropertyChange, json.ToString());
        }

        private static void SendPropertyChange(string propName, string value, int tab) {
            var json = JObject.FromObject(new {propName, value, tab});
            Context.DispatchEvent(WebViewEvent.OnPropertyChange, json.ToString());
        }

        private static void OnDownloadUpdated(object sender, DownloadItem downloadItem) {
            if (downloadItem.IsCancelled) {
                Context.DispatchEvent(WebViewEvent.OnDownloadCancel, downloadItem.Id.ToString());
                return;
            }

            if (downloadItem.IsComplete) {
                Context.DispatchEvent(WebViewEvent.OnDownloadComplete, downloadItem.Id.ToString());
                return;
            }

            Context.DispatchEvent(WebViewEvent.OnDownloadProgress, downloadItem.ToJsonString());
        }

        private static void OnBeforeDownload(object sender, DownloadItem downloadItem) { }

        private static void OnKeyEvent(object sender, int e) {
            Context.DispatchEvent(WebViewEvent.OnEscKey, e.ToString());
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
            printToPdf.ContinueWith(_ => { Context.DispatchEvent(WebViewEvent.OnPdfPrinted, ""); },
                TaskContinuationOptions.OnlyOnRanToCompletion);
        }

        public void AddEventListener(string type) {
            if (type == "keyUp") {
                KeyboardHandler.HasKeyUp = true;
            }
            else if (type == "keyDown") {
                KeyboardHandler.HasKeyDown = true;
            }
        }

        public void RemoveEventListener(string type) {
            if (type == "keyUp") {
                KeyboardHandler.HasKeyUp = false;
            }
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
                if (response.Success && response.Result is IJavascriptCallback javascriptCallback) {
                    response = await javascriptCallback.ExecuteAsync("");
                }

                Context.DispatchEvent(WebViewEvent.AsCallbackEvent, response.ToJsonString(callback));
            }
            catch (Exception e) {
                Context.DispatchEvent(WebViewEvent.AsCallbackEvent, e.ToJsonString(callback));
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

        public void DeleteCookies() {
            try {
                foreach (ChromiumWebBrowser browser in _tabs) {
                    browser.GetCookieManager().DeleteCookies();
                }
            }
            catch {
                // ignored
            }
        }

        private static void CefView_Loaded(object sender, RoutedEventArgs e) { }
    }
}