using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Media;
using CefSharp;
using CefSharp.Wpf;


namespace CefSharpLib {
    public class MessageEventArgs : EventArgs {
        public string Type { get; set; }
        public string Message { get; set; }
    }

    public partial class CefPage : Page {
        private string _initialUrl;
        private string _initialHtml;
        private bool _isLoaded = false;
        private bool _isInited = false;
        public delegate void MessageHandler(object sender, MessageEventArgs args);
        public event MessageHandler OnMessageSent;

        //public static string ON_INITIALIZED = "WebView.OnInitialized";
        public static string ON_FAIL = "WebView.OnFail";
        public static string ON_JAVASCRIPT_RESULT = "WebView.OnJavascriptResult";
        private static string ON_PROPERTY_CHANGE = "WebView.OnPropertyChange";
        public ChromiumWebBrowser Browser;

        public CefPage(bool cefBestPerformance, int cefLogSeverity, int remoteDebuggingPort, string cachePath, Dictionary<string, string> settingsDict) {
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
                Browser.SetBinding(ChromiumWebBrowser.AddressProperty, GetNewCefBinding("Address"));
                Browser.SetBinding(ChromiumWebBrowser.TitleProperty, GetNewCefBinding("Title"));
                Browser.SetBinding(ChromiumWebBrowser.IsLoadingProperty, GetNewCefBinding("IsLoading"));
                Browser.SetBinding(ChromiumWebBrowser.CanGoBackProperty, GetNewCefBinding("CanGoBack"));
                Browser.SetBinding(ChromiumWebBrowser.CanGoForwardProperty, GetNewCefBinding("CanGoForward"));

                MainGrid.Children.Add(Browser);
            }

        }

        public class BindingSource {
            private string _address;
            private string _title;
            private bool _isLoading;
            private CefPage _pc;
            public BindingSource(CefPage pc) {
                _pc = pc;
            }

            public string Address {
                set {
                    if (_address == value) return;
                    var props = new StringPropChange() {
                        propName = @"url",
                        value = value
                    };
                    DataContractJsonSerializer js = new DataContractJsonSerializer(typeof(StringPropChange));
                    _pc.SendMessage(ON_PROPERTY_CHANGE, _pc.propsToJSON(js, props));
                    _address = value;
                }
            }

            public string Title {
                set {
                    if (_title == value) return;
                    var props = new StringPropChange() {
                        propName = @"title",
                        value = value
                    };
                    DataContractJsonSerializer js = new DataContractJsonSerializer(typeof(StringPropChange));
                    _pc.SendMessage(ON_PROPERTY_CHANGE, _pc.propsToJSON(js, props));
                    _title = value;
                }
            }

            public bool IsLoading {
                set {
                    if (_isLoading == value) return;
                    var props = new BoolPropChange() {
                        propName = @"isLoading",
                        value = value
                    };
                    DataContractJsonSerializer js = new DataContractJsonSerializer(typeof(BoolPropChange));
                    _pc.SendMessage(ON_PROPERTY_CHANGE, _pc.propsToJSON(js, props));
                    _isLoading = value;
                }
            }

            public bool CanGoBack {
                set {
                    if (_isLoading == value) return;
                    var props = new BoolPropChange() {
                        propName = @"canGoBack",
                        value = value
                    };
                    DataContractJsonSerializer js = new DataContractJsonSerializer(typeof(BoolPropChange));
                    _pc.SendMessage(ON_PROPERTY_CHANGE, _pc.propsToJSON(js, props));
                    _isLoading = value;
                }
            }

            public bool CanGoForward {
                set {
                    if (_isLoading == value) return;
                    var props = new BoolPropChange() {
                        propName = @"canGoForward",
                        value = value
                    };
                    DataContractJsonSerializer js = new DataContractJsonSerializer(typeof(BoolPropChange));
                    _pc.SendMessage(ON_PROPERTY_CHANGE, _pc.propsToJSON(js, props));
                    _isLoading = value;
                }
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


        [DataContract]
        class StringPropChange {
            [DataMember]
            public string propName { get; set; }
            [DataMember]
            public string value { get; set; }
        }

        [DataContract]
        class BoolPropChange {
            [DataMember]
            public string propName { get; set; }
            [DataMember]
            public bool value { get; set; }
        }


        [DataContract]
        class JavaScriptResultProps {
            [DataMember]
            public string result { get; set; }

            [DataMember]
            public string error { get; set; }
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

        public void EvaluateJavaScript(string javascript) {
            Browser?.GetMainFrame().EvaluateScriptAsync(javascript).ContinueWith(x => {
                var response = x.Result;
                if (response.Success && response.Result != null) {
                    var props = new JavaScriptResultProps() {
                        result = (string)response.Result,
                        error = ""
                    };
                    DataContractJsonSerializer js = new DataContractJsonSerializer(typeof(JavaScriptResultProps));
                    SendMessage(ON_JAVASCRIPT_RESULT, propsToJSON(js, props));
                }
            });
        }

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

        private string propsToJSON(DataContractJsonSerializer js, object props) {
            MemoryStream msObj = new MemoryStream();
            js.WriteObject(msObj, props);
            msObj.Position = 0;
            StreamReader sr = new StreamReader(msObj);
            return sr.ReadToEnd();
        }

    }
}
