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
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Interop;
using System.Windows.Media;
using CefSharp;
using Newtonsoft.Json;
using TuaRua.FreSharp;
using TuaRua.FreSharp.Utils;
using Color = System.Windows.Media.Color;
using FREObject = System.IntPtr;
using FREContext = System.IntPtr;
using Hwnd = System.IntPtr;
using TuaRua.FreSharp.Exceptions;

namespace CefSharpLib {
    public enum PopupBehaviour {
        Block = 0,
        NewWindow,
        SameWindow
    }

    public class MainController : FreSharpMainController {
        private CefView _view;
        private Hwnd _airWindow;
        private Hwnd _cefWindow;
        private Color _backgroundColor;
        private const double ZoomIncrement = 0.10;
        private double _scaleFactor = 1.0;

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
                    {"addTab", AddTab},
                    {"closeTab", CloseTab},
                    {"setCurrentTab", SetCurrentTab},
                    {"getCurrentTab", GetCurrentTab},
                    {"getTabDetails", GetTabDetails},
                    {"addEventListener", AddEventListener},
                    {"removeEventListener", RemoveEventListener},
                };

            return FunctionsDict.Select(kvp => kvp.Key).ToArray();
        }

        private FREObject Capture(FREContext ctx, uint argc, FREObject[] argv) {
            var rect = new WinApi.Rect();
            WinApi.GetWindowRect(_cefWindow, ref rect);
            try {
                var freX = argv[0].AsInt();
                var freY = argv[1].AsInt();
                var freW = argv[2].AsInt();
                var freH = argv[3].AsInt();

                var width = freW > 0 ? freW : rect.right - rect.left;
                var height = freH > 0 ? freH : rect.bottom - rect.top;

                var bmp = new Bitmap(width, height, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
                var graphics = Graphics.FromImage(bmp);
                graphics.CopyFromScreen(rect.left + freX, rect.top + freY, 0, 0, new Size(width, height),
                    CopyPixelOperation.SourceCopy);
                return bmp.ToFREObject();
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }
        }

        private static FREObject IsSupported(FREContext ctx, uint argc, FREObject[] argv) {
            return true.ToFREObject();
        }

        private static FREObject AllowsMagnification(FREContext ctx, uint argc, FREObject[] argv) {
            return true.ToFREObject();
        }

        private FREObject ZoomIn(FREContext ctx, uint argc, FREObject[] argv) {
            var task = _view.CurrentBrowser.GetZoomLevelAsync();
            task.ContinueWith(previous => {
                if (previous.Status == TaskStatus.RanToCompletion) {
                    var currentLevel = previous.Result;
                    _view.CurrentBrowser.SetZoomLevel(currentLevel + ZoomIncrement);
                }
                else {
                    throw new InvalidOperationException("Unexpected failure of calling CEF->GetZoomLevelAsync",
                        previous.Exception);
                }
            }, TaskContinuationOptions.ExecuteSynchronously);
            return FREObject.Zero;
        }

        private FREObject ZoomOut(FREContext ctx, uint argc, FREObject[] argv) {
            var task = _view.CurrentBrowser.GetZoomLevelAsync();
            task.ContinueWith(previous => {
                if (previous.Status == TaskStatus.RanToCompletion) {
                    var currentLevel = previous.Result;
                    _view.CurrentBrowser.SetZoomLevel(currentLevel - ZoomIncrement);
                }
                else {
                    throw new InvalidOperationException("Unexpected failure of calling CEF->GetZoomLevelAsync",
                        previous.Exception);
                }
            }, TaskContinuationOptions.ExecuteSynchronously);
            return FREObject.Zero;
        }

        private FREObject BrowserFocus(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CurrentBrowser.Focus();
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
                var e = new Exception(
                    "Cannot find AIR window to attach webView to. Ensure you init the ANE AFTER your main Sprite is initialised. " +
                    "Please see https://forum.starling-framework.org/topic/webviewane-for-osx/page/7?replies=201#post-105524 for more details");
                return new FreException(e).RawValue;
            }

            try {
                var viewPort = argv[1].AsRect(); //viewPort
                var inFre2 = argv[2]; //settings
                var inFre4 = argv[4]; //backgroundColor
                var cefSettingsFre = inFre2.GetProp("cef");
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

                var whiteList = inFre2.GetProp("urlWhiteList").ToArrayList();
                var blackList = inFre2.GetProp("urlBlackList").ToArrayList();
                _backgroundColor = inFre4.AsColor(true);
                _scaleFactor = useHiDpi ? WinApi.GetScaleFactor() : 1.0;
                
                CefView.Context = Context;
                _view = new CefView {
                    InitialUrl = argv[0].AsString(),
                    Background = new SolidColorBrush(_backgroundColor),
                    X = Convert.ToInt32(viewPort.X * _scaleFactor),
                    Y = Convert.ToInt32(viewPort.Y * _scaleFactor),
                    ViewWidth = Convert.ToInt32(viewPort.Width * _scaleFactor),
                    ViewHeight = Convert.ToInt32(viewPort.Height * _scaleFactor),
                    RemoteDebuggingPort = cefSettingsFre.GetProp("remoteDebuggingPort").AsInt(),
                    CachePath = cefSettingsFre.GetProp("cachePath").AsString(),
                    CacheEnabled = inFre2.GetProp("cacheEnabled").AsBool(),
                    LogLevel = cefSettingsFre.GetProp("logSeverity").AsInt(),
                    BrowserSubprocessPath = cefSettingsFre.GetProp("browserSubprocessPath").AsString(),
                    ContextMenuEnabled = cefSettingsFre.GetProp("contextMenu").GetProp("enabled").AsBool(),
                    EnableDownloads = cefSettingsFre.GetProp("enableDownloads").AsBool(),
                    UserAgent = inFre2.GetProp("userAgent").AsString(),
                    CommandLineArgs = argsDict,
                    WhiteList = whiteList,
                    BlackList = blackList,
                    PopupBehaviour = (PopupBehaviour) inFre2.GetProp("popup").GetProp("behaviour").AsInt(),
                    PopupDimensions = new Tuple<int, int>(
                        inFre2.GetProp("popup").GetProp("dimensions").GetProp("width").AsInt(),
                        inFre2.GetProp("popup").GetProp("dimensions").GetProp("height").AsInt()
                    )
                };
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
            var source = new HwndSource(parameters) {RootVisual = _view};
            _cefWindow = source.Handle;

            WinApi.RegisterTouchWindow(_cefWindow, TouchWindowFlags.TWF_WANTPALM);

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
                var tmp = new FREObject().Init("Vector.<com.tuarua.webview.TabDetails>", null);
                var vecTabDetails = new FREArray(tmp);
                for (var index = 0; index < tabDetails.Count; index++) {
                    var tabDetail = tabDetails[index] as TabDetails;
                    if (tabDetail == null) continue;
                    var currentTabFre = new FREObject().Init("com.tuarua.webview.TabDetails", 
                        index,
                        string.IsNullOrEmpty(tabDetail.Address) ? "" : tabDetail.Address,
                        string.IsNullOrEmpty(tabDetail.Title) ? "" : tabDetail.Title, 
                        tabDetail.IsLoading, 
                        tabDetail.CanGoBack, 
                        tabDetail.CanGoForward, 
                        1.0);

                    vecTabDetails.Set((uint) index, new FreObjectSharp(currentTabFre)); //TODO update FreSharp to allow FREObjects to be passed
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
                WinApi.ShowWindow(_cefWindow, visible ? ShowWindowCommands.SW_SHOWNORMAL : ShowWindowCommands.SW_HIDE);
                WinApi.UpdateWindow(_cefWindow);
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
            WinApi.SetWindowPos(_cefWindow, new Hwnd(0), _view.X, _view.Y, _view.ViewWidth, _view.ViewHeight, flgs);
            WinApi.UpdateWindow(_cefWindow);
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
            _view.CurrentBrowser.Reload();
            return FREObject.Zero;
        }

        public FREObject ReloadFromOrigin(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CurrentBrowser.Reload(true);
            return FREObject.Zero;
        }

        public FREObject StopLoading(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CurrentBrowser.Stop();
            return FREObject.Zero;
        }

        public FREObject BackForwardList(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        public FREObject Go(FREContext ctx, uint argc, FREObject[] argv) {
            return FREObject.Zero;
        }

        public FREObject GoBack(FREContext ctx, uint argc, FREObject[] argv) {
            if (_view.CurrentBrowser.CanGoBack) {
                _view.CurrentBrowser.Back();
            }
            return FREObject.Zero;
        }

        public FREObject GoForward(FREContext ctx, uint argc, FREObject[] argv) {
            if (_view.CurrentBrowser.CanGoForward) {
                _view.CurrentBrowser.Forward();
            }
            return FREObject.Zero;
        }

        public FREObject ShutDown(FREContext ctx, uint argc, FREObject[] argv) {
            OnFinalize();
            return FREObject.Zero;
        }

        public FREObject ShowDevTools(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CurrentBrowser.ShowDevTools();
            return FREObject.Zero;
        }

        public FREObject CloseDevTools(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CurrentBrowser.CloseDevTools();
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
                    EvaluateJavaScript(js);
                }
                else {
                    var callback = callbackFre.AsString();
                    EvaluateJavaScript(js, callback);
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
                    CallJavascriptFunction(js);
                }
                else {
                    var callback = callbackFre.AsString();
                    CallJavascriptFunction(js, callback);
                }
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }
            return FREObject.Zero;
        }

        public async void CallJavascriptFunction(string js, string cb) {
            //this is as->js->as
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            JsonWriter writer;
            try {
                var mf = _view.CurrentBrowser.GetMainFrame();
                var response = await mf.EvaluateScriptAsync(Utils.ToUtf8(js), TimeSpan.FromMilliseconds(500).ToString());

                if (response.Success && response.Result is IJavascriptCallback) {
                    response = await ((IJavascriptCallback) response.Result).ExecuteAsync("");
                }

                writer = new JsonTextWriter(sw) {Formatting = Formatting.None};
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
                }
                else {
                    writer.WriteNull();
                }
                writer.WriteEndObject();
            }
            catch (Exception e) {
                Console.WriteLine(@"JS error: " + e.Message);
                writer = new JsonTextWriter(sw) {Formatting = Formatting.None};
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
            Context.SendEvent(CefView.AsCallbackEvent, sb.ToString());
        }

        public void CallJavascriptFunction(string js) {
            //this is as->js
            try {
                var mf = _view.CurrentBrowser.GetMainFrame();
                mf.ExecuteJavaScriptAsync(Utils.ToUtf8(js)); // this is fire and forget can run js urls, startLine 
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
                writer = new JsonTextWriter(sw) {Formatting = Formatting.None};
                var mf = _view.CurrentBrowser.GetMainFrame();
                var response = await mf.EvaluateScriptAsync(Utils.ToUtf8(js), TimeSpan.FromMilliseconds(500).ToString());
                if (response.Success && response.Result is IJavascriptCallback) {
                    response = await ((IJavascriptCallback) response.Result).ExecuteAsync("");
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
                }
                else {
                    writer.WriteNull();
                }
                writer.WriteEndObject();
            }
            catch (Exception e) {
                Console.WriteLine(@"EvaluateJavaScript JS error: " + e.Message);
                writer = new JsonTextWriter(sw) {Formatting = Formatting.None};
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
            Context.SendEvent(CefView.AsCallbackEvent, sb.ToString());
        }

        public void EvaluateJavaScript(string js) {
            try {
                var mf = _view.CurrentBrowser.GetMainFrame();
                mf.ExecuteJavaScriptAsync(Utils.ToUtf8(js)); // this is fire and forget can run js urls, startLine 
            }
            catch (Exception e) {
                Console.WriteLine(@"JS error: " + e.Message);
            }
        }

        public FREObject Print(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CurrentBrowser.Print();
            return FREObject.Zero;
        }

        public FREObject PrintToPdf(FREContext ctx, uint argc, FREObject[] argv) {
            try {
                var path = argv[0].AsString();
                var printToPdf = _view.CurrentBrowser.PrintToPdfAsync(path);
                printToPdf.ContinueWith(_ => { Context.SendEvent(CefView.OnPdfPrinted, ""); },
                    TaskContinuationOptions.OnlyOnRanToCompletion);
            }
            catch (Exception e) {
                return new FreException(e).RawValue;
            }
            return FREObject.Zero;
        }

        public FREObject AddEventListener(FREContext ctx, uint argc, FREObject[] argv) {
            var type = argv[0].AsString();
            switch (type) {
                case "keyUp":
                    _view.KeyboardHandler.HasKeyUp = true;
                    break;
                case "keyDown":
                    _view.KeyboardHandler.HasKeyDown = true;
                    break;
            }
            return FREObject.Zero;
        }

        public FREObject RemoveEventListener(FREContext ctx, uint argc, FREObject[] argv) {
            var type = argv[0].AsString();
            switch (type) {
                case "keyUp":
                    _view.KeyboardHandler.HasKeyUp = false;
                    break;
                case "keyDown":
                    _view.KeyboardHandler.HasKeyDown = false;
                    break;
            }
            return FREObject.Zero;
        }

        public CefView GetView() {
            return _view;
        }

        public override void OnFinalize() {
            Cef.Shutdown();
        }
    }
}