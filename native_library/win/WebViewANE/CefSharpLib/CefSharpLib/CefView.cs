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

        public string UserAgent { get; set; }
        public Dictionary<string, string> CommandLineArgs { get; set; }

        public ChromiumWebBrowser Browser;
        private bool _isLoaded;
        private string _initialHtml;
        private string _address;
        private string _title;
        private bool _isLoading;
        private bool _canGoBack;
        private bool _canGoForward;

        public const string AsCallbackEvent = "TRWV.as.CALLBACK";
        private const string OnDownloadProgress = "WebView.OnDownloadProgress";
        private const string OnDownloadComplete = "WebView.OnDownloadComplete";
        private const string OnDownloadCancel = "WebView.OnDownloadCancel";
        private const string OnPropertyChange = "WebView.OnPropertyChange";
        private const string OnEscKey = "WebView.OnEscKey";
        private const string OnFail = "WebView.OnFail";
        private const string OnPermission = "WebView.OnPermissionResult";

        public void Init() {
            InitializeComponent();
            IsManipulationEnabled = true;
            // ReSharper disable once UseObjectOrCollectionInitializer
            var host = new WindowsFormsHost();
            host.IsManipulationEnabled = true;

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
                Browser = new ChromiumWebBrowser(InitialUrl) {
                    Dock = DockStyle.Fill
                };

                Browser.RegisterAsyncJsObject("webViewANE", new BoundObject(), BindingOptions.DefaultBinder);


                // ReSharper disable once UseObjectOrCollectionInitializer
                var dh = new DownloadHandler();
                dh.OnDownloadUpdatedFired += OnDownloadUpdatedFired;
                dh.OnBeforeDownloadFired += OnDownloadFired;

                // ReSharper disable once UseObjectOrCollectionInitializer
                var kh = new KeyboardHandler();
                kh.OnKeyEventFired += OnKeyEventFired;

                if (EnableDownloads)
                    Browser.DownloadHandler = dh;
                Browser.KeyboardHandler = kh;

                // ReSharper disable once UseObjectOrCollectionInitializer
                var gh = new GeolocationHandler();
                gh.OnPermissionResult += OnPermissionResult;
                Browser.GeolocationHandler = gh;


                Browser.FrameLoadEnd += OnFrameLoaded;
                Browser.AddressChanged += OnBrowserAddressChanged;
                Browser.TitleChanged += OnBrowserTitleChanged;
                Browser.LoadingStateChanged += OnBrowserLoadingStateChanged;
                Browser.LoadError += OnLoadError;
                Browser.IsBrowserInitializedChanged += OnBrowserInitialized;
                Browser.StatusMessage += OnStatusMessage;
                host.Child = Browser;

                MainGrid.Children.Add(host);

            }

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
            SendPropertyChange(@"url", _address);
        }

        private void OnBrowserTitleChanged(object sender, TitleChangedEventArgs e) {
            if (_title == e.Title) return;
            _title = e.Title;
            SendPropertyChange(@"title", _title);
        }

        private void OnBrowserLoadingStateChanged(object sender, LoadingStateChangedEventArgs e) {
            if (_isLoading == e.IsLoading) return;
            _isLoading = e.IsLoading;
            SendPropertyChange(@"isLoading", _isLoading);

            if (!_isLoading) {
                Browser.Focus();
            }

            if (_canGoForward != e.CanGoForward) {
                _canGoForward = e.CanGoForward;
                SendPropertyChange(@"canGoForward", _canGoForward);
            }

            if (_canGoBack == e.CanGoBack) return;
            _canGoBack = e.CanGoBack;
            SendPropertyChange(@"canGoBack", _canGoBack);
        }

        private static void OnLoadError(object sender, LoadErrorEventArgs e) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            writer.WriteStartObject();
            writer.WritePropertyName("url");
            writer.WriteValue(e.FailedUrl);
            writer.WritePropertyName("errorCode");
            writer.WriteValue(e.ErrorCode);
            writer.WritePropertyName("errorText");
            writer.WriteValue(e.ErrorText);
            writer.WriteEndObject();
            FreSharpController.FreHelper.DispatchEvent(OnFail, sb.ToString());
        }

        private void OnBrowserInitialized(object sender, IsBrowserInitializedChangedEventArgs e) {
            _isLoaded = e.IsBrowserInitialized;
            if (!_isLoaded) return;
            if (!string.IsNullOrEmpty(Browser.Address)) return;
            if (!string.IsNullOrEmpty(_initialHtml)) {
                LoadHtmlString(_initialHtml, InitialUrl);
            } else if (!string.IsNullOrEmpty(InitialUrl)) {
                Load(InitialUrl);
            }
        }

        public void Load(string url) {
            if (_isLoaded) {
                Browser.Load(url);
            } else {
                InitialUrl = url;
            }
        }

        public void LoadHtmlString(string html, string url) {
            if (_isLoaded) {
                Browser.LoadHtml(html, url);
            } else {
                _initialHtml = html;
                InitialUrl = url;
            }
        }

        private static void OnStatusMessage(object sender, StatusMessageEventArgs e) {
            SendPropertyChange(@"statusMessage", e.Value);
        }

        private static void SendPropertyChange(string propName, bool value) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            writer.WriteStartObject();
            writer.WritePropertyName("propName");
            writer.WriteValue(propName);
            writer.WritePropertyName("value");
            writer.WriteValue(value);
            writer.WriteEndObject();
            FreSharpController.FreHelper.DispatchEvent(OnPropertyChange, sb.ToString());
        }

        private static void SendPropertyChange(string propName, string value) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            writer.WriteStartObject();
            writer.WritePropertyName("propName");
            writer.WriteValue(propName);
            writer.WritePropertyName("value");
            writer.WriteValue(value);
            writer.WriteEndObject();
            FreSharpController.FreHelper.DispatchEvent(OnPropertyChange, sb.ToString());
        }

        private static void OnDownloadUpdatedFired(object sender, DownloadItem downloadItem) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            if (downloadItem.IsCancelled) {
                FreSharpController.FreHelper.DispatchEvent(OnDownloadCancel, downloadItem.Id.ToString());
                return;
            }

            if (downloadItem.IsComplete) {
                FreSharpController.FreHelper.DispatchEvent(OnDownloadComplete, downloadItem.Id.ToString());
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
            FreSharpController.FreHelper.DispatchEvent(OnDownloadProgress, sb.ToString());
        }

        private static void OnDownloadFired(object sender, DownloadItem downloadItem) {
        }

        private static void OnKeyEventFired(object sender, int e) {
            FreSharpController.FreHelper.DispatchEvent(OnEscKey, e.ToString());
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
            FreSharpController.FreHelper.DispatchEvent(OnPermission, sb.ToString());
        }

        private static void CefView_Loaded(object sender, RoutedEventArgs e) {
        }


    }
}