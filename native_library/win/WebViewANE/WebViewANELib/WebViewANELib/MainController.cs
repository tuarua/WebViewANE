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
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Windows.Interop;
using System.Windows.Media;
using CefSharp;
using TuaRua.FreSharp;
using TuaRua.FreSharp.Utils;
using Color = System.Drawing.Color;
using FREObject = System.IntPtr;
using FREContext = System.IntPtr;
using Hwnd = System.IntPtr;
using TuaRua.FreSharp.Exceptions;
using TuaRua.FreSharp.Geom;
using WebViewANELib.Touch;
using WinApi = TuaRua.FreSharp.Utils.WinApi;
using System.Diagnostics;

namespace WebViewANELib {
    public class MainController : FreSharpMainController {
        private IWebView _view;
        private Hwnd _airWindow;
        private Hwnd _webViewWindow;
        private Color _backgroundColor;
        private double _scaleFactor = 1.0;
        private Bitmap _capturedBitmapData;
        private const string OnCaptureComplete = "WebView.OnCaptureComplete";
        private bool _useHiDpi;

        public string[] GetFunctions() {
            FunctionsDict =
                new Dictionary<string, Func<FREObject, uint, FREObject[], FREObject>> {
                    {"injectScript", InjectScript},
                    {"shutDown", ShutDown},
                    {"clearCache", ClearCache},
                    {"go", Go},
                    {"goBack", GoBack},
                    {"goForward", GoForward},
                    {"load", Load},
                    {"loadFileURL", LoadFileUrl},
                    {"loadHTMLString", LoadHtmlString},
                    {"reload", Reload},
                    {"reloadFromOrigin", ReloadFromOrigin},
                    {"stopLoading", StopLoading},
                    {"clearRequestHeaders", ClearRequestHeaders},
                    {"backForwardList", BackForwardList},
                    {"allowsMagnification", AllowsMagnification},
                    {"zoomIn", ZoomIn},
                    {"zoomOut", ZoomOut},
                    {"focus", BrowserFocus},
                    {"showDevTools", ShowDevTools},
                    {"closeDevTools", CloseDevTools},
                    {"onFullScreen", OnFullScreen},
                    {"callJavascriptFunction", CallJavascriptFunction},
                    {"evaluateJavaScript", EvaluateJavaScript},
                    {"print", Print},
                    {"printToPdf", PrintToPdf},
                    {"setVisible", SetVisible},
                    {"setViewPort", SetViewPort},
                    {"init", InitView},
                    {"capture", Capture},
                    {"getCapturedBitmapData", GetCapturedBitmapData},
                    {"addTab", AddTab},
                    {"closeTab", CloseTab},
                    {"setCurrentTab", SetCurrentTab},
                    {"getCurrentTab", GetCurrentTab},
                    {"getTabDetails", GetTabDetails},
                    {"addEventListener", AddEventListener},
                    {"removeEventListener", RemoveEventListener},
                    {"getOsVersion", GetOsVersion},
                    {"deleteCookies", DeleteCookies},
                };

            return FunctionsDict.Select(kvp => kvp.Key).ToArray();
        }

        private FREObject GetCapturedBitmapData(FREContext ctx, uint argc, FREObject[] argv) {
            return _capturedBitmapData.ToFREObject();
        }

        private FREObject Capture(FREContext ctx, uint argc, FREObject[] argv) {
            var rect = new WinApi.Rect();
            WinApi.GetWindowRect(_webViewWindow, ref rect);
            var x = 0;
            var y = 0;
            var width = rect.right - rect.left;
            var height = rect.bottom - rect.top;
            try {
                var freCropTo = argv[0];
                if (freCropTo != FREObject.Zero) {
                    var cropTo = freCropTo.AsRect();
                    x = Convert.ToInt32(cropTo.X);
                    y = Convert.ToInt32(cropTo.Y);
                    var freW = Convert.ToInt32(cropTo.Width);
                    var freH = Convert.ToInt32(cropTo.Height);
                    width = freW > 0 ? freW : width;
                    height = freH > 0 ? freH : height;
                }

                _capturedBitmapData = new Bitmap(width, height, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
                var graphics = Graphics.FromImage(_capturedBitmapData);
                graphics.CopyFromScreen(rect.left + x, rect.top + y, 0, 0, new Size(width, height),
                    CopyPixelOperation.SourceCopy);

                DispatchEvent(OnCaptureComplete, "");
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private static FREObject AllowsMagnification(FREContext ctx, uint argc, FREObject[] argv) {
            return true.ToFREObject();
        }

        private FREObject ZoomIn(FREContext ctx, uint argc, FREObject[] argv) {
            _view.ZoomIn();
            return FREObject.Zero;
        }

        private FREObject ZoomOut(FREContext ctx, uint argc, FREObject[] argv) {
            _view.ZoomOut();
            return FREObject.Zero;
        }

        private FREObject BrowserFocus(FREContext ctx, uint argc, FREObject[] argv) {
            _view.ForceFocus();
            return FREObject.Zero;
        }

        private FREObject InjectScript(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                var injectCodeFre = argv[0];
                var injectScriptUrlFre = argv[1];
                var injectStartLineFre = argv[2];
                if (FreObjectTypeSharp.String == injectCodeFre.Type()) {
                    _view.InjectCode = injectCodeFre.AsString();
                }

                if (FreObjectTypeSharp.String == injectScriptUrlFre.Type()) {
                    _view.InjectScriptUrl = injectScriptUrlFre.AsString();
                }

                _view.InjectStartLine = injectStartLineFre.AsInt();
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject InitView(FREContext ctx, uint argc, FREObject[] argv) {
            FreSharpLogger.GetInstance().Context = Context;
            _airWindow = Process.GetCurrentProcess().MainWindowHandle;
            if (_airWindow == Hwnd.Zero) {
                return new FreException(
                        "Cannot find AIR window to attach webView to. Ensure you init the ANE AFTER your main Sprite is initialized. " +
                        "Please see https://forum.starling-framework.org/topic/webviewane-for-osx/page/7?replies=201#post-105524 for more details")
                    .RawValue;
            }

            bool useTransparentBackground;
            try {
                dynamic settings = new FreObjectSharp(argv[2]);
                
                UrlRequestHeaderManager.GetInstance().PersistRequestHeaders = settings.persistRequestHeaders;
                dynamic cefSettings = new FreObjectSharp(settings.cef);
                var freUrl = argv[0];
                UrlRequest initialUrl = null;
                if (FreObjectTypeSharp.Null != freUrl.Type()) {
                    initialUrl = new UrlRequest(freUrl);
                    UrlRequestHeaderManager.GetInstance().Add(initialUrl);
                }

                var viewPort = argv[1].AsRect();

                useTransparentBackground = settings.useTransparentBackground;
                FREArray clArr = cefSettings.commandLineArgs;

                var argsDict = new Dictionary<string, string>();
                foreach (var argFre in clArr) {
                    var key = argFre.GetProp("key").AsString();
                    var val = argFre.GetProp("value").AsString();
                    if (string.IsNullOrEmpty(key) || string.IsNullOrEmpty(val)) continue;
                    argsDict.Add(key, val);
                }
                
                ArrayList whiteList = settings.urlWhiteList.AsArrayList();
                ArrayList blackList = settings.urlBlackList.AsArrayList();

                _backgroundColor = argv[4].AsColor();
                var backgroundMediaColor = new System.Windows.Media.Color {
                    A = _backgroundColor.A,
                    R = _backgroundColor.R,
                    G = _backgroundColor.G,
                    B = _backgroundColor.B
                };

                _useHiDpi = settings.useHiDPI;

                if (Environment.OSVersion.Version.Major > 7) {
                    _scaleFactor = _useHiDpi ? WinApi.GetScaleFactor(_airWindow) : 1.0;
                } else {
                    _scaleFactor = _useHiDpi ? WinApi.GetScaleFactor() : 1.0;
                }

                CefView.Context = Context;
                dynamic contextMenu = new FreObjectSharp(settings.contextMenu);
                dynamic popup = new FreObjectSharp(settings.popup);
                dynamic dimensions = new FreObjectSharp(popup.dimensions);

                _view = new CefView {
                    Background = new SolidColorBrush(backgroundMediaColor),
                    RemoteDebuggingPort = cefSettings.remoteDebuggingPort,
                    EnablePrintPreview = cefSettings.enablePrintPreview,
                    DisableFileDialog = settings.disableFileDialog,
                    CachePath = cefSettings.cachePath,
                    DownloadPath = settings.downloadPath,
                    EnableDownloads = settings.enableDownloads,
                    CacheEnabled = settings.cacheEnabled,
                    LogLevel = cefSettings.logSeverity,
                    AcceptLanguageList = cefSettings.acceptLanguageList,
                    Locale = cefSettings.locale,
                    ContextMenuEnabled = contextMenu.enabled,
                    UserAgent = settings.userAgent,
                    UserDataPath = cefSettings.userDataPath,
                    CommandLineArgs = argsDict,
                    PopupBehaviour = (PopupBehaviour) popup.behaviour,
                    PopupDimensions = new Tuple<int, int>(dimensions.width, dimensions.height),
                    ScaleFactor = _scaleFactor
                };

                _view.InitialUrl = initialUrl;
                _view.WhiteList = whiteList;
                _view.BlackList = blackList;
                _view.X = Convert.ToInt32(viewPort.X * _scaleFactor);
                _view.Y = Convert.ToInt32(viewPort.Y * _scaleFactor);
                _view.ViewWidth = Convert.ToInt32(viewPort.Width * _scaleFactor);
                _view.ViewHeight = Convert.ToInt32(viewPort.Height * _scaleFactor);
                _view.Init();
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            var parameters = new HwndSourceParameters();
            parameters.SetPosition(_view.X, _view.Y);
            parameters.SetSize(_view.ViewWidth, _view.ViewHeight);
            parameters.ParentWindow = _airWindow;
            parameters.WindowName = "Cef Window";
            parameters.WindowStyle = (int) WindowStyles.WS_CHILD;
            parameters.AcquireHwndFocusInMenuMode = true;

            if (useTransparentBackground && Environment.OSVersion.Version.Major > 7) {
                parameters.ExtendedWindowStyle = (int) WindowExStyles.WS_EX_LAYERED;
                parameters.UsesPerPixelTransparency = true;
            }

            var source = new HwndSource(parameters) {RootVisual = (CefView) _view};

            if (useTransparentBackground && source.CompositionTarget != null) {
                source.CompositionTarget.BackgroundColor = Colors.Transparent;
            }

            _webViewWindow = source.Handle;

            MessageTouchDevice.RegisterTouchWindow(_webViewWindow);

            return FREObject.Zero;
        }

        private FREObject AddTab(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                _view.InitialUrl = new UrlRequest(argv[0]);
                _view.AddTab();
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject CloseTab(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                _view.CloseTab(argv[0].AsInt());
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject SetCurrentTab(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                _view.SetCurrentTab(argv[0].AsInt());
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject GetCurrentTab(FREContext ctx, uint argc, FREObject[] argv) {
            return _view.CurrentTab.ToFREObject();
        }

        private FREObject GetTabDetails(FREContext ctx, uint argc, FREObject[] argv) {
            var tabDetails = _view.TabDetails;
            try {
                var vecTabDetails = new FREArray("com.tuarua.webview.TabDetails", tabDetails.Count, true);
                for (var index = 0; index < tabDetails.Count; index++) {
                    if (!(tabDetails[index] is TabDetails tabDetail)) continue;
                    var currentTabFre = new FREObject().Init("com.tuarua.webview.TabDetails",
                        index,
                        string.IsNullOrEmpty(tabDetail.Address) ? "" : tabDetail.Address,
                        string.IsNullOrEmpty(tabDetail.Title) ? "" : tabDetail.Title,
                        tabDetail.IsLoading,
                        tabDetail.CanGoBack,
                        tabDetail.CanGoForward,
                        1.0);

                    vecTabDetails.Set((uint) index, currentTabFre);
                }

                return vecTabDetails.RawValue;
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }
        }

        private FREObject SetVisible(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                var visible = argv[0].AsBool();
                WinApi.ShowWindow(_webViewWindow,
                    visible ? ShowWindowCommands.SW_SHOWNORMAL : ShowWindowCommands.SW_HIDE);
                WinApi.UpdateWindow(_webViewWindow);
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject SetViewPort(FREContext ctx, uint argc, FREObject[] argv) {
            System.Windows.Rect viewPort;
            try {
                viewPort = argv[0].AsRect();
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            if (Environment.OSVersion.Version.Major > 7) {
                _scaleFactor = _useHiDpi ? WinApi.GetScaleFactor(_airWindow) : 1.0;
            } else {
                _scaleFactor = _useHiDpi ? WinApi.GetScaleFactor() : 1.0;
            }

           
            _view.ScaleFactor = _scaleFactor;

            var tmpX = Convert.ToInt32(viewPort.X * _scaleFactor);
            var tmpY = Convert.ToInt32(viewPort.Y * _scaleFactor);
            var tmpWidth = Convert.ToInt32(viewPort.Width * _scaleFactor);
            var tmpHeight = Convert.ToInt32(viewPort.Height * _scaleFactor);

            var updateWidth = false;
            var updateHeight = false;
            var updateX = false;
            var updateY = false;

            if (tmpWidth != _view.ViewWidth) {
                _view.ViewWidth = tmpWidth;
                updateWidth = true;
            }

            if (tmpHeight != _view.ViewHeight) {
                _view.ViewHeight = tmpHeight;
                updateHeight = true;
            }

            if (tmpX != _view.X) {
                _view.X = tmpX;
                updateX = true;
            }

            if (tmpY != _view.Y) {
                _view.Y = tmpY;
                updateY = true;
            }

            if (!updateX && !updateY && !updateWidth && !updateHeight) return FREObject.Zero;
            var flags = (WindowPositionFlags) 0;
            if (!updateWidth && !updateHeight) {
                flags |= WindowPositionFlags.SWP_NOSIZE;
            }

            if (!updateX && !updateY) {
                flags |= WindowPositionFlags.SWP_NOMOVE;
            }

            WinApi.SetWindowPos(_webViewWindow, new Hwnd(0), _view.X, _view.Y, _view.ViewWidth, _view.ViewHeight,
                flags);
            WinApi.UpdateWindow(_webViewWindow);
            return FREObject.Zero;
        }

        private FREObject Load(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                var request = new UrlRequest(argv[0]);
                UrlRequestHeaderManager.GetInstance().Add(request);
                _view.Load(request, argc > 1 ? argv[1].AsString() : null);
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject LoadFileUrl(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                _view.Load(new UrlRequest(argv[0].AsString()), argc > 1 ? argv[1].AsString() : null);
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject LoadHtmlString(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                var html = argv[0].AsString();
                var freUrl = argv[1];
                _view.LoadHtmlString(html, FreObjectTypeSharp.Null == freUrl.Type()
                    ? null
                    : new UrlRequest(freUrl)
                );
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject Reload(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Reload();
            return FREObject.Zero;
        }

        private FREObject ReloadFromOrigin(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Reload(true);
            return FREObject.Zero;
        }

        private FREObject StopLoading(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Stop();
            return FREObject.Zero;
        }

        private FREObject ClearRequestHeaders(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                UrlRequestHeaderManager.GetInstance().Remove();
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject BackForwardList(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        private FREObject Go(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        private FREObject GoBack(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Back();
            return FREObject.Zero;
        }

        private FREObject GoForward(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Forward();
            return FREObject.Zero;
        }

        private FREObject ShutDown(FREContext ctx, uint argc, FREObject[] argv) {
            OnFinalize();
            return FREObject.Zero;
        }

        private FREObject ShowDevTools(FREContext ctx, uint argc, FREObject[] argv) {
            _view.ShowDevTools();
            return FREObject.Zero;
        }

        private FREObject CloseDevTools(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CloseDevTools();
            return FREObject.Zero;
        }

        private FREObject ClearCache(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        private FREObject OnFullScreen(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        private FREObject EvaluateJavaScript(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                var js = argv[0].AsString();
                var callbackFre = argv[1];

                if (FreObjectTypeSharp.Null == callbackFre.Type()) {
                    _view.EvaluateJavaScript(js);
                }
                else {
                    var callback = callbackFre.AsString();
                    _view.EvaluateJavaScript(js, callback);
                }
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject CallJavascriptFunction(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                var js = argv[0].AsString();
                var callbackFre = argv[1];
                if (FreObjectTypeSharp.Null == callbackFre.Type()) {
                    _view.EvaluateJavaScript(js);
                }
                else {
                    var callback = callbackFre.AsString();
                    _view.EvaluateJavaScript(js, callback);
                }
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        private FREObject Print(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Print();
            return FREObject.Zero;
        }

        private FREObject PrintToPdf(FREContext ctx, uint argc, FREObject[] argv) {
            var path = argv[0].AsString();
            if (!string.IsNullOrEmpty(path)) {
                _view.PrintToPdfAsync(path);
            }

            return FREObject.Zero;
        }

        private FREObject AddEventListener(FREContext ctx, uint argc, FREObject[] argv) {
            _view.AddEventListener(argv[0].AsString());
            return FREObject.Zero;
        }

        private FREObject RemoveEventListener(FREContext ctx, uint argc, FREObject[] argv) {
            _view.RemoveEventListener(argv[0].AsString());
            return FREObject.Zero;
        }

        private FREObject GetOsVersion(FREContext ctx, uint argc, FREObject[] argv) {
            return new[] {
                Environment.OSVersion.Version.Major,
                Environment.OSVersion.Version.Minor,
                Environment.OSVersion.Version.Build
            }.ToFREObject();
        }

        private FREObject DeleteCookies(FREContext ctx, uint argc, FREObject[] argv) {
            _view.DeleteCookies();
            return FREObject.Zero;
        }

        public override void OnFinalize() {
            Cef.Shutdown();
        }

        public override string TAG => "MainController";
    }
}