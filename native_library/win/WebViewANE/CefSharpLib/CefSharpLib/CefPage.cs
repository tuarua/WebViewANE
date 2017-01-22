using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Windows;
using System.Windows.Data;
using CefSharp;
using CefSharp.Wpf;
using Newtonsoft.Json;


namespace CefSharpLib {

    public partial class CefPage {
        private string _initialUrl;
        private string _initialHtml;
        private bool _isLoaded = false;
        // private bool _isInited = false;

        private const string AS_CALLBACK_EVENT = "TRWV.as.CALLBACK";

        public delegate void MessageHandler(object sender, MessageEventArgs args);
        public event MessageHandler OnMessageSent;

        //public static string ON_INITIALIZED = "WebView.OnInitialized";
        public static string ON_FAIL = "WebView.OnFail";
        public static string ON_JAVASCRIPT_RESULT = "WebView.OnJavascriptResult";
        public ChromiumWebBrowser Browser;

        public CefPage(bool cefBestPerformance, int cefLogSeverity, int remoteDebuggingPort, string cachePath,
            Dictionary<string, string> settingsDict) {
            InitializeComponent();
            Loaded += CefPage_Loaded;


            //Console.WriteLine(Cef.ChromiumVersion);

            //https://github.com/cefsharp/CefSharp/blob/master/CefSharp.Example/CefExample.cs#L37
            CefSettings settings = new CefSettings {
                RemoteDebuggingPort = remoteDebuggingPort,
                CachePath = cachePath
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


            if (cefBestPerformance)
                settings.SetOffScreenRenderingBestPerformanceArgs();

            foreach (KeyValuePair<string, string> kvp in settingsDict) {
                settings.CefCommandLineArgs.Add(kvp.Key, kvp.Value);
            }

            if (Cef.Initialize(settings)) {
                Browser = new ChromiumWebBrowser();
                Browser.RegisterJsObject("webViewANE", new BoundObject(this), BindingOptions.DefaultBinder);
                Browser.SetBinding(ChromiumWebBrowser.AddressProperty, GetNewCefBinding("Address"));
                Browser.SetBinding(ChromiumWebBrowser.TitleProperty, GetNewCefBinding("Title"));
                Browser.SetBinding(ChromiumWebBrowser.IsLoadingProperty, GetNewCefBinding("IsLoading"));
                Browser.SetBinding(ChromiumWebBrowser.CanGoBackProperty, GetNewCefBinding("CanGoBack"));
                Browser.SetBinding(ChromiumWebBrowser.CanGoForwardProperty, GetNewCefBinding("CanGoForward"));

                MainGrid.Children.Add(Browser);
            }

        }






        private Binding GetNewCefBinding(string name) {
            return new Binding {
                Path = new PropertyPath(name),
                Source = new BindingSource(this),
                Mode = BindingMode.OneWayToSource,
                UpdateSourceTrigger = UpdateSourceTrigger.PropertyChanged
            };
        }

        public virtual void SendMessage(string type, string message) {
            //Console.WriteLine(@"SendMessage in C# type: " + type +  @" message:" + message);
            MessageHandler handler = OnMessageSent;   // make a copy to be more thread-safe
            var args = new MessageEventArgs() { Type = type, Message = message };  // this part will vary
            handler?.Invoke(this, args);
        }

        public void TearDown() {
            Console.WriteLine(@"TearDown");
            Browser.Dispose();
            Cef.Shutdown();
        }

        private void CefPage_Loaded(object sender, RoutedEventArgs e) {
            _isLoaded = true;

            if (!string.IsNullOrEmpty(_initialHtml)) {
                LoadHtmlString(_initialHtml, _initialUrl);
            } else if (!string.IsNullOrEmpty(_initialUrl)) {
                Load(_initialUrl);
            }

        }

        //References
        //https://github.com/cefsharp/CefSharp/blob/master/CefSharp.WinForms.Example/BrowserTabUserControl.cs
        //https://github.com/cefsharp/CefSharp/blob/CefSharp1/CefSharp.Example/ExamplePresenter.cs#L263
        //https://www.codeproject.com/Articles/887148/Display-HTML-in-WPF-and-CefSharp-Tutorial-Part
        //https://github.com/cefsharp/CefSharp/wiki/Frequently-asked-questions#CallJSWithResult
        //https://gist.github.com/amaitland/9d354376960b0cd9305a#file-oneplusone-cs


        public void Load(string url) {
            if (_isLoaded) {
                Browser.Address = url;
                // Browser.Load(url);
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

        public void SetMagnification(double value) {
            Browser.SetZoomLevel(value);
        }

        public double GetMagnification() {
            return Browser.ZoomLevel;
        }

        public void ShowDevTools() { Browser.ShowDevTools(); }
        public void CloseDevTools() { Browser.CloseDevTools(); }


        public async void CallJavascriptFunction(string s, string cb) { //this is as->js->as
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            JsonWriter writer;
            try {
                var mf = Browser.GetMainFrame();
                var response = await mf.EvaluateScriptAsync(s);
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

                Console.WriteLine(response.Result);

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

            SendMessage(AS_CALLBACK_EVENT, sb.ToString());
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
                var response = await mf.EvaluateScriptAsync(js);
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
                //better
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
            SendMessage(AS_CALLBACK_EVENT, sb.ToString());
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
