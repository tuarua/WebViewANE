using System;
using System.Collections;
using System.Threading.Tasks;
using Microsoft.Toolkit.Win32.UI.Controls.Interop.WinRT;
using Microsoft.Toolkit.Win32.UI.Controls.WPF;
using Newtonsoft.Json.Linq;
using TuaRua.FreSharp;

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
        public string InitialUrl { private get; set; }
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
                VerticalAlignment = System.Windows.VerticalAlignment.Stretch,
                HorizontalAlignment = System.Windows.HorizontalAlignment.Stretch,
                IsJavaScriptEnabled = true,
                IsIndexedDBEnabled = true,
                IsPrivateNetworkClientServerCapabilityEnabled = true,
                IsScriptNotifyAllowed = true,
            };

            browser.NavigationStarting += OnBrowserAddressChanged;
            browser.ContentLoading += OnBrowserLoadingStateChanged;
            browser.DOMContentLoaded += OnBrowserTitleChanged;
            browser.NavigationCompleted += OnNavigationCompleted;
            browser.NewWindowRequested += OnNewWindowRequested;
            browser.ScriptNotify += OnScriptNotify;

            if (!string.IsNullOrEmpty(InitialUrl)) {
                browser.Navigate(new Uri(InitialUrl));
            }

            _tabs.Add(browser);
            TabDetails.Add(new TabDetails());

            return browser;
        }

        private void OnScriptNotify(object sender, WebViewControlScriptNotifyEventArgs e) {
            Context.SendEvent("TRACE", e.Value);
        }

        private void OnBrowserAddressChanged(object sender, WebViewControlNavigationStartingEventArgs e) {
            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(sender)) continue;
                var tabDetails = GetTabDetails(index);
                var url = e.Uri.AbsoluteUri;
                if (tabDetails.Address == url) {
                    return;
                }

                tabDetails.Address = url;
                SendPropertyChange(@"url", url, index);
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

                if (tabDetails.CanGoBack == browser.CanGoBack) {
                    return;
                }

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
            /*Context.SendEvent("TRACE", e.IsSuccess
                ? $@"NavigationCompleted: {e.Uri}"
                : $@"WebErrorStatus: {e.WebErrorStatus}");*/

            var browser = (WebView) sender;

            for (var index = 0; index < _tabs.Count; index++) {
                if (!_tabs[index].Equals(browser)) continue;
                var tabDetails = GetTabDetails(index);
                if (!tabDetails.IsLoading) {
                    return;
                }

                tabDetails.IsLoading = false;
                SendPropertyChange(@"isLoading", false, index);
            }
        }

        private void OnNewWindowRequested(object sender, WebViewControlNewWindowRequestedEventArgs e) {
            Context.SendEvent("TRACE", $@"NewWindowRequested: {e.Uri}");
        }

        private TabDetails GetTabDetails(int tab) {
            return (TabDetails) TabDetails[tab];
        }

        public void AddTab() {
            Context.SendEvent("TRACE", "AddTab Unavailable in Edge");
        }

        public void SetCurrentTab(int index) {
            Context.SendEvent("TRACE", "SetCurrentTab Unavailable in Edge");
        }

        public void CloseTab(int index) {
            Context.SendEvent("TRACE", "CloseTab Unavailable in Edge");
        }

        private static void SendPropertyChange(string propName, bool value, int tab) {
            var json = JObject.FromObject(new {propName, value, tab});
            Context.SendEvent(WebViewEvent.OnPropertyChange, json.ToString());
        }

        private static void SendPropertyChange(string propName, string value, int tab) {
            var json = JObject.FromObject(new {propName, value, tab});
            Context.SendEvent(WebViewEvent.OnPropertyChange, json.ToString());
        }

        // will need a separate parser for local files
        public void Load(string url) {
            CurrentBrowser.Navigate(new Uri(url));
        }

        public void LoadHtmlString(string html, string url) {
            CurrentBrowser.NavigateToString(html);
        }

        public void ZoomIn() {
            Context.SendEvent("TRACE", "ZoomIn Unavailable in Edge");
        }

        public void ZoomOut() {
            Context.SendEvent("TRACE", "ZoomOut Unavailable in Edge");
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
            Context.SendEvent("TRACE", "Print Unavailable in Edge");
        }

        public void PrintToPdfAsync(string path) {
            Context.SendEvent("TRACE", "PrintToPdfAsync Unavailable in Edge");
        }

        public void AddEventListener(string type) {
            Context.SendEvent("TRACE", "AddEventListener Unavailable in Edge");
        }

        public void RemoveEventListener(string type) {
            Context.SendEvent("TRACE", "RemoveEventListener Unavailable in Edge");
        }

        public void ShowDevTools() {
            Context.SendEvent("TRACE", "ShowDevTools Unavailable in Edge");
        }

        public void CloseDevTools() {
            Context.SendEvent("TRACE", "CloseDevTools Unavailable in Edge");
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
                    Context.SendEvent(WebViewEvent.AsCallbackEvent, json.ToString());
                }
                else {
                    json = JObject.FromObject(new {
                        message = (string) null,
                        error = previous.Exception?.Message,
                        result = (object) null,
                        success = false,
                        callbackName = callback
                    });
                    Context.SendEvent(WebViewEvent.AsCallbackEvent, json.ToString());
                }
            }, TaskContinuationOptions.ExecuteSynchronously);
        }

        public void EvaluateJavaScript(string javascript) {
            CurrentBrowser.InvokeScript("eval", javascript);
        }

    }
}