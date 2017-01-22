using System;
namespace CefSharpLib {
    public class MessageEventArgs : EventArgs {
        public string Type { get; set; }
        public string Message { get; set; }
    }
}