using System;
using System.Windows.Forms;
using CefSharp;
using CefSharp.WinForms.Internals;

namespace CefSharpLib {
    internal class GeolocationHandler : IGeolocationHandler {
        public event EventHandler<bool> OnPermissionResult;
        bool IGeolocationHandler.OnRequestGeolocationPermission(IWebBrowser browserControl, IBrowser browser, string requestingUrl, int requestId, IGeolocationCallback callback) {
            //The callback has been disposed, so we are unable to continue
            if (callback.IsDisposed) {
                var handler = OnPermissionResult;
                handler?.Invoke(this, false);
                return false;
            }

            var control = (Control)browserControl;
            control.InvokeOnUiThreadIfRequired(delegate {
                //Callback wraps a managed resource, so we'll wrap in a using statement so it's always disposed of.
                using (callback) {
                    var message = requestingUrl + "wants to use your computer's location.  Allow?";
                    var result = MessageBox.Show(message, @"Geolocation", MessageBoxButtons.YesNo);
                    callback.Continue(result == DialogResult.Yes);
                    var handler = OnPermissionResult;
                    handler?.Invoke(this, result == DialogResult.Yes);
                }
            });

            //To cancel the request immediately we'd return false here, as we're returning true
            // the callback will be used to allow/deny the permission request.
            return true;
        }

        void IGeolocationHandler.OnCancelGeolocationPermission(IWebBrowser browserControl, IBrowser browser, int requestId) {
            Console.WriteLine(@"cancelled permission");
            var handler = OnPermissionResult;
            handler?.Invoke(this, false);
        }
    }
}
