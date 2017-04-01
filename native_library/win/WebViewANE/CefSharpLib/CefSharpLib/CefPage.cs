using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Media;
using System.Windows.Forms;
using System.Windows.Forms.Integration;
using CefSharp;
using CefSharp.WinForms;
using Newtonsoft.Json;

namespace CefSharpLib {

    public partial class CefPage {
        private string _initialUrl;

        private string _injectScriptUrl;
        private int _injectStartLine;
        private string _injectCode;

        private string _initialHtml;
        private bool _isLoaded;

        private const string AsCallbackEvent = "TRWV.as.CALLBACK";
        private const string ON_CONSOLE_MESSAGE = "WebView.OnConsoleMessage";
        private const string OnDownloadProgress = "WebView.OnDownloadProgress";
        private const string OnDownloadComplete = "WebView.OnDownloadComplete";
        private const string OnDownloadCancel = "WebView.OnDownloadCancel";
        private const string OnPropertyChange = "WebView.OnPropertyChange";
        private const string OnEscKey = "WebView.OnEscKey";
        private const string OnFail = "WebView.OnFail";

        public delegate void MessageHandler(object sender, MessageEventArgs args);
        public event MessageHandler OnMessageSent;

        
        public ChromiumWebBrowser Browser;

        private string _address;
        private string _title;
        private bool _isLoading;
        private bool _canGoBack;
        private bool _canGoForward;

        public CefPage(string initialUrl, string userAgent, int cefLogSeverity, int remoteDebuggingPort, string cachePath,
            Dictionary<string, string> settingsDict, string cefBrowserSubprocessPath, byte r, byte g, byte b, bool enableDownloads)
        {
            _initialUrl = initialUrl;
            InitializeComponent();
            IsManipulationEnabled = true;
            var host = new WindowsFormsHost();
            host.IsManipulationEnabled = true;
            
            Background = new SolidColorBrush(Color.FromRgb(r, g, b));
            Loaded += CefPage_Loaded;
            var settings = new CefSettings {
                RemoteDebuggingPort = remoteDebuggingPort,
                CachePath = cachePath,
                UserAgent = userAgent
            };

            CefSharpSettings.ShutdownOnExit = false;
           
            switch (cefLogSeverity) {
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
            settings.BrowserSubprocessPath = cefBrowserSubprocessPath;

            foreach (var kvp in settingsDict) {
                settings.CefCommandLineArgs.Add(kvp.Key, kvp.Value);
            }

            Cef.EnableHighDPISupport();
            if (Cef.Initialize(settings))
            {
                Browser = new ChromiumWebBrowser(_initialUrl)
                {
                    Dock = DockStyle.Fill
                };

                Browser.RegisterAsyncJsObject("webViewANE", new BoundObject(this), BindingOptions.DefaultBinder);


                // ReSharper disable once UseObjectOrCollectionInitializer
                var dh = new DownloadHandler();
                dh.OnDownloadUpdatedFired += OnDownloadUpdatedFired;
                dh.OnBeforeDownloadFired += OnDownloadFired;

                var kh = new KeyboardHandler();
                kh.OnKeyEventFired += OnKeyEventFired;

                if(enableDownloads)
                    Browser.DownloadHandler = dh;
                Browser.KeyboardHandler = kh;
                Browser.FrameLoadEnd += OnFrameLoaded;
                Browser.AddressChanged += OnBrowserAddressChanged;
                Browser.TitleChanged += OnBrowserTitleChanged;
                Browser.LoadingStateChanged += OnBrowserLoadingStateChanged;
                Browser.LoadError += OnLoadError;
                Browser.IsBrowserInitializedChanged += OnBrowserInitialized;

                //Browser.LifeSpanHandler.OnBeforePopup();

                // Browser.ConsoleMessage += OnConsoleMessage;
                Browser.StatusMessage += OnStatusMessage;

                host.Child = Browser;

                MainGrid.Children.Add(host);

            }

        }

        private void OnBrowserInitialized(object sender, IsBrowserInitializedChangedEventArgs e) {
            _isLoaded = e.IsBrowserInitialized;
            if (!_isLoaded) return;
            if (!string.IsNullOrEmpty(Browser.Address)) return;
            if (!string.IsNullOrEmpty(_initialHtml)) {
                LoadHtmlString(_initialHtml, _initialUrl);
            } else if (!string.IsNullOrEmpty(_initialUrl)) {
                Load(_initialUrl);
            }
        }

        private void OnKeyEventFired(object sender, int e) {
            SendMessage(OnEscKey, e.ToString());
        }

        private void OnLoadError(object sender, LoadErrorEventArgs e) {
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
            SendMessage(OnFail, sb.ToString());
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

            if (_canGoBack != e.CanGoBack) {
                _canGoBack = e.CanGoBack;
                SendPropertyChange(@"canGoBack", _canGoBack);
            }

           
        }

        private void OnBrowserTitleChanged(object sender, TitleChangedEventArgs e) {
            if (_title == e.Title) return;
            _title = e.Title;
            SendPropertyChange(@"title", _title);
        }


        private void OnBrowserAddressChanged(object sender, AddressChangedEventArgs e) {
            if (_address == e.Address) return;
            _address = e.Address;
            SendPropertyChange(@"url", _address);
        }

        private void OnStatusMessage(object sender, StatusMessageEventArgs e) {
            SendPropertyChange(@"statusMessage", e.Value);
        }

        private void OnFrameLoaded(object sender, FrameLoadEndEventArgs e) {
            if (!e.Frame.IsMain) return;
            if (!string.IsNullOrEmpty(_injectCode) || !string.IsNullOrEmpty(_injectScriptUrl)) {
                e.Frame.ExecuteJavaScriptAsync(_injectCode, _injectScriptUrl, _injectStartLine);
            }
        }


        private void OnConsoleMessage(object sender, ConsoleMessageEventArgs args) {
           // Console.WriteLine(args.Line + args.Message);
        }

        private void OnDownloadFired(object sender, DownloadItem downloadItem) {
            /*
            Console.WriteLine(@"D Fired-------------------------");
            Console.WriteLine(downloadItem.Id);
            Console.WriteLine(downloadItem.Url);
            Console.WriteLine(downloadItem.FullPath);
            Console.WriteLine(downloadItem.IsComplete);
           // Console.WriteLine(downloadItem.MimeType);
            Console.WriteLine(@"-------------------------");*/
        }

        private void OnDownloadUpdatedFired(object sender, DownloadItem downloadItem) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);

            if (downloadItem.IsCancelled) {
                SendMessage(OnDownloadCancel, downloadItem.Id.ToString());
                return;
            }

            if (downloadItem.IsComplete) {
                SendMessage(OnDownloadComplete, downloadItem.Id.ToString());
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
            SendMessage(OnDownloadProgress, sb.ToString());
        }

        private void SendPropertyChange(string propName, bool value) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            writer.WriteStartObject();
            writer.WritePropertyName("propName");
            writer.WriteValue(propName);
            writer.WritePropertyName("value");
            writer.WriteValue(value);
            writer.WriteEndObject();
            SendMessage(OnPropertyChange, sb.ToString());
        }

        private void SendPropertyChange(string propName, string value) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            var writer = new JsonTextWriter(sw);
            writer.WriteStartObject();
            writer.WritePropertyName("propName");
            writer.WriteValue(propName);
            writer.WritePropertyName("value");
            writer.WriteValue(value);
            writer.WriteEndObject();
            SendMessage(OnPropertyChange, sb.ToString());
        }

        public virtual void SendMessage(string type, string message) {
            //Console.WriteLine(@"SendMessage in C# type: " + type +  @" message:" + message);
            var handler = OnMessageSent;   // make a copy to be more thread-safe
            var args = new MessageEventArgs { Type = type, Message = message };  // this part will vary
            handler?.Invoke(this, args);
        }

        public void ShutDown() {
            Cef.Shutdown();
        }

        private void CefPage_Loaded(object sender, RoutedEventArgs e) {
        }

        public void Load(string url) {
            if (_isLoaded) {
                Browser.Load(url);
            } else {
                _initialUrl = url;
            }
        }

        public void LoadHtmlString(string html, string url) {
            if (_isLoaded) {
                Browser.LoadHtml(html, url);
            } else {
                _initialHtml = html;
                _initialUrl = url;
            }
        }

        public void InjectScript(string code, string scriptUrl, uint startLine) {
            _injectCode = code;
            _injectScriptUrl = scriptUrl;
            _injectStartLine = (int)startLine;
        }

        public void Reload() {
            Browser.Reload();
        }

        public void ReloadFromOrigin() {
            Browser.Reload(true);
        }

        public void GoForward() {
            if (Browser.CanGoForward)
                Browser.Forward();
        }

        public void GoBack() {
            if (Browser.CanGoBack)
                Browser.Back();
        }

        public void StopLoading() {
            Browser.Stop();
        }

        public void Print() {
            Browser.Print();
        }

        public void SetMagnification(double value) {
            Browser.SetZoomLevel(value);
        }

        public double GetMagnification() {
            var task = Browser.GetZoomLevelAsync();
            task.ContinueWith(previous => previous.Status == TaskStatus.RanToCompletion ? previous.Result : 1.0, TaskContinuationOptions.ExecuteSynchronously);
            return 1.0;
        }

        public void ShowDevTools() { Browser.ShowDevTools(); }
        public void CloseDevTools() { Browser.CloseDevTools(); }

        public async void CallJavascriptFunction(string s, string cb) { //this is as->js->as
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            JsonWriter writer;
            try {
                var mf = Browser.GetMainFrame();
                var response = await mf.EvaluateScriptAsync(s, TimeSpan.FromMilliseconds(500).ToString());

                if (response.Success && response.Result is IJavascriptCallback) {
                    response = await ((IJavascriptCallback)response.Result).ExecuteAsync("");
                }

                writer = new JsonTextWriter(sw) { Formatting = Formatting.None };
                writer.WriteStartObject();
                writer.WritePropertyName("callbackName");
                writer.WriteValue(cb);
                writer.WritePropertyName("success");
                writer.WriteValue(response.Success);
                writer.WritePropertyName("message");
                writer.WriteValue(response.Message);
                writer.WritePropertyName("error");
                writer.WriteNull();
                writer.WritePropertyName("result");

                if (response.Success && response.Result != null) {
                    writer.WriteRawValue(JsonConvert.SerializeObject(response.Result, Formatting.None));
                } else {
                    writer.WriteNull();
                }
                writer.WriteEndObject();

            }
            catch (Exception e) {

                Console.WriteLine(@"JS error: " + e.Message);

                writer = new JsonTextWriter(sw) { Formatting = Formatting.None };
                writer.WriteStartObject();
                writer.WritePropertyName("message");
                writer.WriteNull();
                writer.WritePropertyName("error");
                writer.WriteValue(e.Message);
                writer.WritePropertyName("result");
                writer.WriteNull();
                writer.WritePropertyName("success");
                writer.WriteValue(false);
                writer.WritePropertyName("callbackName");
                writer.WriteValue(cb);
                writer.WriteEndObject();

            }

            SendMessage(AsCallbackEvent, sb.ToString());
        }

        public void CallJavascriptFunction(string js) { //this is as->js
            try {
                var mf = Browser.GetMainFrame();
                mf.ExecuteJavaScriptAsync(js); // this is fire and forget can run js urls, startLine 
            }
            catch (Exception e) {
                Console.WriteLine(@"JS error: " + e.Message);
            }
        }

        public async void EvaluateJavaScript(string js, string cb) {
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            JsonWriter writer;
            try {
                writer = new JsonTextWriter(sw) { Formatting = Formatting.None };
                var mf = Browser.GetMainFrame();
                var response = await mf.EvaluateScriptAsync(js, TimeSpan.FromMilliseconds(500).ToString());
                if (response.Success && response.Result is IJavascriptCallback) {
                    response = await ((IJavascriptCallback)response.Result).ExecuteAsync("");
                }
                writer.WriteStartObject();
                writer.WritePropertyName("success");
                writer.WriteValue(response.Success);
                writer.WritePropertyName("message");
                writer.WriteValue(response.Message);
                writer.WritePropertyName("error");
                writer.WriteNull();
                writer.WritePropertyName("callbackName");
                writer.WriteValue(cb);
                writer.WritePropertyName("result");

                if (response.Success && response.Result != null) {
                    writer.WriteRawValue(JsonConvert.SerializeObject(response.Result, Formatting.None));
                } else {
                    writer.WriteNull();
                }
                writer.WriteEndObject();
            }
            catch (Exception e) {
                Console.WriteLine(@"EvaluateJavaScript JS error: " + e.Message);
                writer = new JsonTextWriter(sw) { Formatting = Formatting.None };
                writer.WriteStartObject();
                writer.WritePropertyName("message");
                writer.WriteNull();
                writer.WritePropertyName("error");
                writer.WriteValue(e.Message);
                writer.WritePropertyName("result");
                writer.WriteNull();
                writer.WritePropertyName("success");
                writer.WriteValue(false);
                writer.WritePropertyName("guid");
                writer.WriteValue(cb);
                writer.WriteEndObject();

            }
            SendMessage(AsCallbackEvent, sb.ToString());
        }

        public void EvaluateJavaScript(string js) {
            try {
                var mf = Browser.GetMainFrame();
                mf.ExecuteJavaScriptAsync(js); // this is fire and forget can run js urls, startLine 
            }
            catch (Exception e) {
                Console.WriteLine(@"JS error: " + e.Message);
            }
        }
    }

    
}
