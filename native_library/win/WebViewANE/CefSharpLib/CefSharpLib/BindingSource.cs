using System.IO;
using System.Text;
using Newtonsoft.Json;

namespace CefSharpLib {
    class BindingSource {
        private static string ON_PROPERTY_CHANGE = "WebView.OnPropertyChange";
        private string _address;
        private string _title;
        private bool _isLoading;
        private bool _canGoBack;
        private bool _canGoForward;
        private CefPage _pc;
        private StringBuilder _sb;
        private StringWriter _sw;
        private JsonWriter _writer;

        public BindingSource(CefPage pc) {
            _pc = pc;
        }

        private void SendMessage(string propName, string value) {
            _sb = new StringBuilder();
            _sw = new StringWriter(_sb);
            _writer = new JsonTextWriter(_sw);
            _writer.WriteStartObject();
            _writer.WritePropertyName("propName");
            _writer.WriteValue(propName);
            _writer.WritePropertyName("value");
            _writer.WriteValue(value);
            _writer.WriteEndObject();
            _pc.SendMessage(ON_PROPERTY_CHANGE, _sb.ToString());
        }

        private void SendMessage(string propName, bool value) {
            _sb = new StringBuilder();
            _sw = new StringWriter(_sb);
            _writer = new JsonTextWriter(_sw);
            _writer.WriteStartObject();
            _writer.WritePropertyName("propName");
            _writer.WriteValue(propName);
            _writer.WritePropertyName("value");
            _writer.WriteValue(value);
            _writer.WriteEndObject();
            _pc.SendMessage(ON_PROPERTY_CHANGE, _sb.ToString());
        }

        public string Address {
            set {
                if (_address == value) return;
                _address = value;
                SendMessage(@"url", value);
            }
        }

        public string Title {
            set {
                if (_title == value) return;
                _title = value;
                SendMessage(@"title", value);
            }
        }

        public bool IsLoading {
            set {
                if (_isLoading == value) return;
                _isLoading = value;
                SendMessage(@"isLoading", value);
                if (!_isLoading) {
                    _pc.Browser.Focus();
                }

            }
        }

        public bool CanGoBack {
            set {
                if (_canGoBack == value) return;
                _canGoBack = value;
                SendMessage(@"canGoBack", value);

            }
        }

        public bool CanGoForward {
            set {
                if (_canGoForward == value) return;
                _canGoForward = value;
                SendMessage(@"canGoForward", value);
            }
        }

    }
}