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
//  No part, or derivative of this Air Native Extensions's code is permitted 
//  to be sold as the basis of a commercially packaged Air Native Extension which 
//  undertakes the same purpose as this software. That is, a WebView for Windows, 
//  OSX and/or iOS and/or Android.
//  All Rights Reserved. Tua Rua Ltd.

#endregion

using System;
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

namespace WebViewANELib {
    public class MainController : FreSharpMainController {
        private IWebView _view;
        private Hwnd _airWindow;
        private Hwnd _webViewWindow;
        private Color _backgroundColor;
        private double _scaleFactor = 1.0;
        private Bitmap _capturedBitmapData;
        private const string OnCaptureComplete = "WebView.OnCaptureComplete";
        private bool _useEdge;

        public string[] GetFunctions() {
            FunctionsDict =
                new Dictionary<string, Func<FREObject, uint, FREObject[], FREObject>> {
                    {"isSupported", IsSupported},
                    {"injectScript", InjectScript},
                    {"shutDown", ShutDown},
                    {"clearCache", ClearCache},
                    {"go", Go},
                    {"goBack", GoBack},
                    {"goForward", GoForward},
                    {"load", Load},
                    {"loadFileURL", Load},
                    {"loadHTMLString", LoadHtmlString},
                    {"reload", Reload},
                    {"reloadFromOrigin", ReloadFromOrigin},
                    {"stopLoading", StopLoading},
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

        private static FREObject IsSupported(FREContext ctx, uint argc, FREObject[] argv) {
            return true.ToFREObject();
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

        public FREObject InjectScript(FREContext ctx, uint argc, FREObject[] argv) {
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

        public FREObject InitView(FREContext ctx, uint argc, FREObject[] argv) {
            _airWindow = System.Diagnostics.Process.GetCurrentProcess().MainWindowHandle;
            if (_airWindow == Hwnd.Zero) {
                return new FreException(
                        "Cannot find AIR window to attach webView to. Ensure you init the ANE AFTER your main Sprite is initialised. " +
                        "Please see https://forum.starling-framework.org/topic/webviewane-for-osx/page/7?replies=201#post-105524 for more details")
                    .RawValue;
            }
            System.Windows.Media.Color backgroundMediaColor;
            try {
                var viewPort = argv[1].AsRect();
                var settingsFre = argv[2];
                var colorFre = argv[4];
                var cefSettingsFre = settingsFre.GetProp("cef");
                var useHiDpi = argv[5].AsBool();
                var clArr = new FREArray(cefSettingsFre.GetProp("commandLineArgs"));
                var argsDict = new Dictionary<string, string>();

                uint i;
                for (i = 0; i < clArr.Length; ++i) {
                    var argFre = clArr.At(i);
                    var key = argFre.GetProp("key").AsString();
                    var val = argFre.GetProp("value").AsString();
                    if (string.IsNullOrEmpty(key) || string.IsNullOrEmpty(val)) continue;
                    argsDict.Add(key, val);
                }

                _useEdge = settingsFre.GetProp("engine").AsInt() == 1;
                var whiteList = settingsFre.GetProp("urlWhiteList").ToArrayList();
                var blackList = settingsFre.GetProp("urlBlackList").ToArrayList();
                _backgroundColor = colorFre.AsColor(true);

                backgroundMediaColor = new System.Windows.Media.Color {
                    A = _backgroundColor.A,
                    R = _backgroundColor.R,
                    G = _backgroundColor.G,
                    B = _backgroundColor.B
                };

                _scaleFactor = useHiDpi ? WinApi.GetScaleFactor() : 1.0;

                if (_useEdge) {
                    EdgeView.Context = Context;
                    _view = new EdgeView {
                        Background = new SolidColorBrush(backgroundMediaColor)
                    };
                }
                else {
                    CefView.Context = Context;
                    _view = new CefView {
                        Background = new SolidColorBrush(backgroundMediaColor),
                        RemoteDebuggingPort = cefSettingsFre.GetProp("remoteDebuggingPort").AsInt(),
                        CachePath = cefSettingsFre.GetProp("cachePath").AsString(),
                        DownloadPath = settingsFre.GetProp("downloadPath").AsString(),
                        EnableDownloads = settingsFre.GetProp("enableDownloads").AsBool(),
                        CacheEnabled = settingsFre.GetProp("cacheEnabled").AsBool(),
                        LogLevel = cefSettingsFre.GetProp("logSeverity").AsInt(),
                        BrowserSubprocessPath = cefSettingsFre.GetProp("browserSubprocessPath").AsString(),
                        ContextMenuEnabled = settingsFre.GetProp("contextMenu").GetProp("enabled").AsBool(),
                        UserAgent = settingsFre.GetProp("userAgent").AsString(),
                        UserDataPath = cefSettingsFre.GetProp("userDataPath").AsString(),
                        CommandLineArgs = argsDict,
                        WhiteList = whiteList,
                        BlackList = blackList,
                        PopupBehaviour = (PopupBehaviour) settingsFre.GetProp("popup").GetProp("behaviour").AsInt(),
                        PopupDimensions = new Tuple<int, int>(
                            settingsFre.GetProp("popup").GetProp("dimensions").GetProp("width").AsInt(),
                            settingsFre.GetProp("popup").GetProp("dimensions").GetProp("height").AsInt()
                        )
                    };
                }
                _view.InitialUrl = argv[0].AsString();
                _view.X = Convert.ToInt32(viewPort.X * _scaleFactor);
                _view.Y = Convert.ToInt32(viewPort.Y * _scaleFactor);
                _view.ViewWidth = Convert.ToInt32(viewPort.Width * _scaleFactor);
                _view.ViewHeight = Convert.ToInt32(viewPort.Height * _scaleFactor);
                _view.Init();
            }
            catch (Exception e) {
                return new FreException(e).RawValue; //return as3 error and throw in swc
            }

            var parameters = new HwndSourceParameters();
            parameters.SetPosition(_view.X, _view.Y);
            parameters.SetSize(_view.ViewWidth, _view.ViewHeight);
            parameters.ParentWindow = _airWindow;
            parameters.WindowName = "Cef Window";
            parameters.WindowStyle = (int) WindowStyles.WS_CHILD;
            parameters.AcquireHwndFocusInMenuMode = true;

            if (Environment.OSVersion.Version.Major > 7) {
                parameters.ExtendedWindowStyle = (int) WindowExStyles.WS_EX_LAYERED;
                parameters.UsesPerPixelTransparency = true;
            }

            var source = _useEdge ? new HwndSource(parameters) {RootVisual = (EdgeView) _view} 
                : new HwndSource(parameters) {RootVisual = (CefView) _view};
            if (source.CompositionTarget != null) {
                source.CompositionTarget.BackgroundColor = backgroundMediaColor;
            }   
            _webViewWindow = source.Handle;

            WinApi.RegisterTouchWindow(_webViewWindow, TouchWindowFlags.TWF_WANTPALM);

            return FREObject.Zero;
        }

        public FREObject AddTab(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                _view.InitialUrl = argv[0].AsString();
                _view.AddTab();
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        public FREObject CloseTab(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                _view.CloseTab(argv[0].AsInt());
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        public FREObject SetCurrentTab(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                _view.SetCurrentTab(argv[0].AsInt());
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        public FREObject GetCurrentTab(FREContext ctx, uint argc, FREObject[] argv) {
            return _view.CurrentTab.ToFREObject();
        }

        public FREObject GetTabDetails(FREContext ctx, uint argc, FREObject[] argv) {
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

        public FREObject SetVisible(FREContext ctx, uint argc, FREObject[] argv) {
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

        public FREObject SetViewPort(FREContext ctx, uint argc, FREObject[] argv) {
            System.Windows.Rect viewPort;
            try {
                viewPort = argv[0].AsRect();
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

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
            var flgs = (WindowPositionFlags) 0;
            if (!updateWidth && !updateHeight) {
                flgs |= WindowPositionFlags.SWP_NOSIZE;
            }

            if (!updateX && !updateY) {
                flgs |= WindowPositionFlags.SWP_NOMOVE;
            }

            WinApi.SetWindowPos(_webViewWindow, new Hwnd(0), _view.X, _view.Y, _view.ViewWidth, _view.ViewHeight, flgs);
            WinApi.UpdateWindow(_webViewWindow);
            return FREObject.Zero;
        }

        public FREObject Load(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                _view.Load(argv[0].AsString());
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        public FREObject LoadHtmlString(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                _view.LoadHtmlString(
                    argv[0].AsString(),
                    argv[1].AsString());
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }

            return FREObject.Zero;
        }

        public FREObject Reload(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Reload();
            return FREObject.Zero;
        }

        public FREObject ReloadFromOrigin(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Reload(true);
            return FREObject.Zero;
        }

        public FREObject StopLoading(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Stop();
            return FREObject.Zero;
        }

        public FREObject BackForwardList(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        public FREObject Go(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        public FREObject GoBack(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Back();
            return FREObject.Zero;
        }

        public FREObject GoForward(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Forward();
            return FREObject.Zero;
        }

        public FREObject ShutDown(FREContext ctx, uint argc, FREObject[] argv) {
            OnFinalize();
            return FREObject.Zero;
        }

        public FREObject ShowDevTools(FREContext ctx, uint argc, FREObject[] argv) {
            _view.ShowDevTools();
            return FREObject.Zero;
        }

        public FREObject CloseDevTools(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CloseDevTools();
            return FREObject.Zero;
        }

        public FREObject ClearCache(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        public FREObject OnFullScreen(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        public FREObject EvaluateJavaScript(FREContext ctx, uint argc, FREObject[] argv) {
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

        public FREObject CallJavascriptFunction(FREContext ctx, uint argc, FREObject[] argv) {
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

        public FREObject Print(FREContext ctx, uint argc, FREObject[] argv) {
            _view.Print();
            return FREObject.Zero;
        }

        public FREObject PrintToPdf(FREContext ctx, uint argc, FREObject[] argv) {
            var path = argv[0].AsString();
            if (!string.IsNullOrEmpty(path)) {
                _view.PrintToPdfAsync(path);
            }

            return FREObject.Zero;
        }

        public FREObject AddEventListener(FREContext ctx, uint argc, FREObject[] argv) {
            _view.AddEventListener(argv[0].AsString());
            return FREObject.Zero;
        }

        public FREObject RemoveEventListener(FREContext ctx, uint argc, FREObject[] argv) {
            _view.RemoveEventListener(argv[0].AsString());
            return FREObject.Zero;
        }

        public FREObject GetOsVersion(FREContext ctx, uint argc, FREObject[] argv) {
            return new[] {
                Environment.OSVersion.Version.Major,
                Environment.OSVersion.Version.Minor,
                Environment.OSVersion.Version.Build
            }.ToFREObject();
        }

        public override void OnFinalize() {
            Cef.Shutdown();
        }
    }
}