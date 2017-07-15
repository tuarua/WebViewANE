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
using TuaRua.FreSharp.Display;
using TuaRua.FreSharp.Geom;
using TuaRua.FreSharp.Utils;
using Color = System.Windows.Media.Color;
using FREObject = System.IntPtr;
using FREContext = System.IntPtr;
using Hwnd = System.IntPtr;

namespace CefSharpLib {
    public enum PopupBehaviour {
        Block = 0,
        NewWindow,
        SameWindow
    }

    public class MainController : FreSharpController {
        private CefView _view;
        private Hwnd _airWindow;
        private Hwnd _cefWindow;
        private Color _backgroundColor;
        private const double ZoomIncrement = 0.10;

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
                    {"addToStage", AddToStage},
                    {"removeFromStage", RemoveFromStage},
                    {"setPositionAndSize", SetPositionAndSize},
                    {"init", InitView},
                    {"capture", Capture},
                    {"addTab", AddTab},
                    {"closeTab", CloseTab},
                    {"setCurrentTab", SetCurrentTab},
                    {"getCurrentTab", GetCurrentTab},
                    {"getTabDetails", GetTabDetails},
                    
                };

            return FunctionsDict.Select(kvp => kvp.Key).ToArray();
        }

        private FREObject Capture(FREContext ctx, uint argc, FREObject[] argv) {
            var rect = new WinApi.Rect();
            WinApi.GetWindowRect(_cefWindow, ref rect);

            var freX = Convert.ToInt32(new FreObjectSharp(argv[0]).Value);
            var freY = Convert.ToInt32(new FreObjectSharp(argv[1]).Value);
            var freW = Convert.ToInt32(new FreObjectSharp(argv[2]).Value);
            var freH = Convert.ToInt32(new FreObjectSharp(argv[3]).Value);

            var width = freW > 0 ? freW : rect.right - rect.left;
            var height = freH > 0 ? freH : rect.bottom - rect.top;

            var bmp = new Bitmap(width, height, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
            var graphics = Graphics.FromImage(bmp);
            graphics.CopyFromScreen(rect.left + freX, rect.top + freY, 0, 0, new Size(width, height),
                CopyPixelOperation.SourceCopy);
            var ret = new FreBitmapDataSharp(bmp);
            return ret.RawValue;
        }

        private static FREObject IsSupported(FREContext ctx, uint argc, FREObject[] argv) {
            return new FreObjectSharp(true).RawValue;
        }

        private static FREObject AllowsMagnification(FREContext ctx, uint argc, FREObject[] argv) {
            return new FreObjectSharp(true).RawValue;
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
            var injectCodeFre = new FreObjectSharp(argv[0]);
            var injectScriptUrlFre = new FreObjectSharp(argv[1]);
            var injectStartLineFre = new FreObjectSharp(argv[2]);

            if (FreObjectTypeSharp.String == injectCodeFre.GetType()) {
                _view.InjectCode = Convert.ToString(injectCodeFre.Value);
            }
            if (FreObjectTypeSharp.String == injectScriptUrlFre.GetType()) {
                _view.InjectScriptUrl = Convert.ToString(injectScriptUrlFre.Value);
            }
            _view.InjectStartLine = Convert.ToInt32(injectStartLineFre.Value);

            return FREObject.Zero;
        }

        public FREObject InitView(FREContext ctx, uint argc, FREObject[] argv) {
            _airWindow = System.Diagnostics.Process.GetCurrentProcess().MainWindowHandle;
            if (_airWindow == Hwnd.Zero) {
                Trace("Cannot find AIR window to attach webView to. Ensure you init the ANE AFTER your main Sprite is initialised. " +
                      "Please see https://forum.starling-framework.org/topic/webviewane-for-osx/page/7?replies=201#post-105524 for more details");
                return FREObject.Zero;
            }    

            var inFre1 = new FreRectangleSharp(argv[1]); //viewport
            var inFre2 = new FreObjectSharp(argv[2]); //settings
            var inFre4 = new FreObjectSharp(argv[4]); //backgroundColor
            var cefSettingsFre = inFre2.GetProperty("cef");

            var googleApiKeyFre = cefSettingsFre.GetProperty("GOOGLE_API_KEY");
            var googleDefaultClientIdFre = cefSettingsFre.GetProperty("GOOGLE_DEFAULT_CLIENT_ID");
            var googleDefaultClientSecretFre = cefSettingsFre.GetProperty("GOOGLE_DEFAULT_CLIENT_SECRET");

            if (FreObjectTypeSharp.String == googleApiKeyFre.GetType()) {
                Environment.SetEnvironmentVariable("GOOGLE_API_KEY", Convert.ToString(googleApiKeyFre.Value));
            }
            if (FreObjectTypeSharp.String == googleDefaultClientIdFre.GetType()) {
                Environment.SetEnvironmentVariable("GOOGLE_DEFAULT_CLIENT_ID",
                    Convert.ToString(googleDefaultClientIdFre.Value));
            }
            if (FreObjectTypeSharp.String == googleDefaultClientSecretFre.GetType()) {
                Environment.SetEnvironmentVariable("GOOGLE_DEFAULT_CLIENT_SECRET",
                    Convert.ToString(googleDefaultClientSecretFre.Value));
            }

            var clArr = new FreArraySharp(cefSettingsFre.GetProperty("commandLineArgs").RawValue);
            var argsDict = new Dictionary<string, string>();

            uint i;
            for (i = 0; i < clArr.Length; ++i) {
                var argFre = clArr.GetObjectAt(i);
                var key = Convert.ToString(argFre.GetProperty("key").Value);
                var val = Convert.ToString(argFre.GetProperty("value").Value);
                if (string.IsNullOrEmpty(key) || string.IsNullOrEmpty(val)) continue;
                argsDict.Add(key, val);
            }

            var whiteList = new FreArraySharp(inFre2.GetProperty("urlWhiteList").RawValue).GetAsArrayList();
            var blackList = new FreArraySharp(inFre2.GetProperty("urlBlackList").RawValue).GetAsArrayList();

            var rgb = FreSharpHelper.GetAsUInt(inFre4.RawValue);
            _backgroundColor = Color.FromRgb(
                Convert.ToByte((rgb >> 16) & 0xff),
                Convert.ToByte((rgb >> 8) & 0xff),
                Convert.ToByte((rgb >> 0) & 0xff));

            var viewPort = inFre1.Value;
            _view = new CefView {
                InitialUrl = Convert.ToString(new FreObjectSharp(argv[0]).Value),
                Background = new SolidColorBrush(_backgroundColor),
                X = viewPort.X,
                Y = viewPort.Y,
                ViewWidth = viewPort.Width,
                ViewHeight = viewPort.Height,
                RemoteDebuggingPort = Convert.ToInt32(cefSettingsFre.GetProperty("remoteDebuggingPort").Value),
                CachePath = Convert.ToString(cefSettingsFre.GetProperty("cachePath").Value),
                CacheEnabled = Convert.ToBoolean(inFre2.GetProperty("cacheEnabled").Value),
                LogLevel = Convert.ToInt32(cefSettingsFre.GetProperty("logSeverity").Value),
                BrowserSubprocessPath = Convert.ToString(cefSettingsFre.GetProperty("browserSubprocessPath").Value),
                ContextMenuEnabled = Convert.ToBoolean(cefSettingsFre.GetProperty("contextMenu").GetProperty("enabled")
                    .Value),
                EnableDownloads = Convert.ToBoolean(cefSettingsFre.GetProperty("enableDownloads").Value),
                UserAgent = Convert.ToString(inFre2.GetProperty("userAgent").Value),
                CommandLineArgs = argsDict,
                WhiteList = whiteList,
                BlackList = blackList,
                PopupBehaviour = (PopupBehaviour) inFre2.GetProperty("popup").GetProperty("behaviour").Value,
                PopupDimensions = new Tuple<int, int>(
                    Convert.ToInt32(inFre2.GetProperty("popup").GetProperty("dimensions").GetProperty("width").Value),
                    Convert.ToInt32(inFre2.GetProperty("popup").GetProperty("dimensions").GetProperty("height").Value)
                )
            };

            _view.Init();

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
            _view.InitialUrl = Convert.ToString(new FreObjectSharp(argv[0]).Value);
            _view.AddTab();
            return FREObject.Zero;
        }

        public FREObject CloseTab(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CloseTab(Convert.ToInt32(new FreObjectSharp(argv[0]).Value));
            return FREObject.Zero;
        }

        public FREObject SetCurrentTab(FREContext ctx, uint argc, FREObject[] argv) {
            _view.SetCurrentTab(Convert.ToInt32(new FreObjectSharp(argv[0]).Value));
            return FREObject.Zero;
        }

        public FREObject GetCurrentTab(FREContext ctx, uint argc, FREObject[] argv) {
            return new FreObjectSharp(_view.CurrentTab).RawValue;
        }

        public FREObject GetTabDetails(FREContext ctx, uint argc, FREObject[] argv) {
            var tabDetails = _view.TabDetails;
            var tmp = new FreObjectSharp("Vector.<com.tuarua.webview.TabDetails>", null);
            var vecTabDetails = new FreArraySharp(tmp.RawValue);
            for (var index = 0; index < tabDetails.Count; index++) {
                var tabDetail = tabDetails[index] as TabDetails;
                if (tabDetail == null) continue;
                var currentTabFre = new FreObjectSharp("com.tuarua.webview.TabDetails", index, tabDetail.Address,
                    tabDetail.Title, tabDetail.IsLoading, tabDetail.CanGoBack, tabDetail.CanGoForward, 1.0);
                vecTabDetails.SetObjectAt(currentTabFre, (uint) index);
            }
            return vecTabDetails.RawValue;
        }

        public FREObject AddToStage(FREContext ctx, uint argc, FREObject[] argv) {
            WinApi.ShowWindow(_cefWindow, ShowWindowCommands.SW_SHOWNORMAL);
            WinApi.UpdateWindow(_cefWindow);
            return FREObject.Zero;
        }

        public FREObject RemoveFromStage(FREContext ctx, uint argc, FREObject[] argv) {
            WinApi.ShowWindow(_cefWindow, ShowWindowCommands.SW_HIDE);
            WinApi.UpdateWindow(_cefWindow);
            return FREObject.Zero;
        }

        public FREObject SetPositionAndSize(FREContext ctx, uint argc, FREObject[] argv) {
            var viewPort = new FreRectangleSharp(argv[0]).Value;

            var tmpX = viewPort.X;
            var tmpY = viewPort.Y;
            var tmpWidth = viewPort.Width;
            var tmpHeight = viewPort.Height;

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
            _view.Load(Convert.ToString(new FreObjectSharp(argv[0]).Value));
            return FREObject.Zero;
        }

        public FREObject LoadHtmlString(FREContext ctx, uint argc, FREObject[] argv) {
            _view.LoadHtmlString(
                Convert.ToString(new FreObjectSharp(argv[0]).Value),
                Convert.ToString(new FreObjectSharp(argv[1]).Value));
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
            if (_view.CurrentBrowser.CanGoBack)
                _view.CurrentBrowser.Back();
            return FREObject.Zero;
        }

        public FREObject GoForward(FREContext ctx, uint argc, FREObject[] argv) {
            if (_view.CurrentBrowser.CanGoForward)
                _view.CurrentBrowser.Forward();
            return FREObject.Zero;
        }

        public FREObject ShutDown(FREContext ctx, uint argc, FREObject[] argv) {
            ShutDown();
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
            var js = Convert.ToString(new FreObjectSharp(argv[0]).Value);
            var callbackFre = new FreObjectSharp(argv[1]);

            if (FreObjectTypeSharp.Null == callbackFre.GetType()) {
                EvaluateJavaScript(js);
            }
            else {
                var callback = Convert.ToString(callbackFre.Value);
                EvaluateJavaScript(js, callback);
            }
            return FREObject.Zero;
        }

        public FREObject CallJavascriptFunction(FREContext ctx, uint argc, FREObject[] argv) {
            var js = Convert.ToString(new FreObjectSharp(argv[0]).Value);
            var callbackFre = new FreObjectSharp(argv[1]);

            if (FreObjectTypeSharp.Null == callbackFre.GetType()) {
                CallJavascriptFunction(js);
            }
            else {
                var callback = Convert.ToString(callbackFre.Value);
                CallJavascriptFunction(js, callback);
            }
            return FREObject.Zero;
        }

        public async void CallJavascriptFunction(string s, string cb) {
            //this is as->js->as
            var sb = new StringBuilder();
            var sw = new StringWriter(sb);
            JsonWriter writer;
            try {
                var mf = _view.CurrentBrowser.GetMainFrame();
                var response = await mf.EvaluateScriptAsync(s, TimeSpan.FromMilliseconds(500).ToString());

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
            Context.DispatchEvent(CefView.AsCallbackEvent, sb.ToString());
        }

        public void CallJavascriptFunction(string js) {
            //this is as->js
            try {
                var mf = _view.CurrentBrowser.GetMainFrame();
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
                writer = new JsonTextWriter(sw) {Formatting = Formatting.None};
                var mf = _view.CurrentBrowser.GetMainFrame();
                var response = await mf.EvaluateScriptAsync(js, TimeSpan.FromMilliseconds(500).ToString());
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
            Context.DispatchEvent(CefView.AsCallbackEvent, sb.ToString());
        }

        public void EvaluateJavaScript(string js) {
            try {
                var mf = _view.CurrentBrowser.GetMainFrame();
                mf.ExecuteJavaScriptAsync(js); // this is fire and forget can run js urls, startLine 
            }
            catch (Exception e) {
                Console.WriteLine(@"JS error: " + e.Message);
            }
        }

        public FREObject Print(FREContext ctx, uint argc, FREObject[] argv) {
            _view.CurrentBrowser.Print();
            return FREObject.Zero;
        }

        public CefView GetView() {
            return _view;
        }

        public void ShutDown() {
            Cef.Shutdown();
        }
    }
}