package {
import com.greensock.TweenLite;
import com.tuarua.BackBtn;
import com.tuarua.CancelBtn;
import com.tuarua.CaptureBtn;
import com.tuarua.DevToolsBtn;
import com.tuarua.ForwardBtn;
import com.tuarua.FreSharp;
import com.tuarua.FreSwift;
import com.tuarua.FullscreenBtn;
import com.tuarua.JsBtn;
import com.tuarua.RefreshBtn;
import com.tuarua.WebBtn;
import com.tuarua.WebView;
import com.tuarua.ZoominBtn;
import com.tuarua.ZoomoutBtn;
import com.tuarua.fre.ANEError;
import com.tuarua.utils.os;
import com.tuarua.webview.ActionscriptCallback;
import com.tuarua.webview.DownloadProgress;
import com.tuarua.webview.JavascriptResult;
import com.tuarua.webview.LogSeverity;
import com.tuarua.webview.Settings;
import com.tuarua.webview.WebViewEvent;
import com.tuarua.webview.popup.Behaviour;

import events.TabEvent;

import flash.desktop.NativeApplication;
import flash.display.BitmapData;
import flash.display.NativeWindowDisplayState;
import flash.display.PNGEncoderOptions;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.system.Capabilities;
import flash.text.Font;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import views.BasicButton;

import views.Input;
import views.Progress;
import views.StatusText;
import views.TabBar;

[SWF(width="1280", height="800", frameRate="60", backgroundColor="#F1F1F1")]
public class Main extends Sprite {
    public static const FONT:Font = new FiraSansSemiBold();
    private var freSharpANE:FreSharp = new FreSharp(); // must create before all others
    private var freSwiftANE:FreSwift = new FreSwift(); // must create before all others
    private var webView:WebView;

    private var backBtn:SimpleButton = new BackBtn();
    private var fwdBtn:SimpleButton = new BackBtn();
    private var refreshBtn:SimpleButton = new RefreshBtn();
    private var cancelBtn:SimpleButton = new CancelBtn();
    private var zoomInBtn:SimpleButton = new ZoominBtn();
    private var zoomOutBtn:SimpleButton = new ZoomoutBtn();
    private var fullscreenBtn:SimpleButton = new FullscreenBtn();
    private var devToolsBtn:SimpleButton = new DevToolsBtn();
    private var jsBtn:SimpleButton = new JsBtn();
    private var webBtn:SimpleButton = new WebBtn();
    private var capureBtn:SimpleButton = new CaptureBtn();

    private var as_js_as_Btn:BasicButton = new BasicButton("AS->JS->AS with Callback");
    private var eval_js_Btn:BasicButton = new BasicButton("AS->JS- with no Callback");

    private var statusTxt:StatusText = new StatusText();
    private var progress:Progress = new Progress();
    private var urlInput:Input = new Input();

    private var tabBar:TabBar = new TabBar();

    private var hasActivated:Boolean;
    private var _appWidth:uint = 1280;
    private var _appHeight:uint = 800;
    private static const newTabUrls:Vector.<String> = new <String>["https://www.bing.com", "https://www.bbc.co.uk",
        null, "https://www.github.com", "https://forum.starling-framework.org/"];

    public function Main() {
        super();
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        this.addEventListener(Event.ACTIVATE, onActivated);
        NativeApplication.nativeApplication.executeInBackground = true;
    }

    protected function onActivated(event:Event):void {
        if (hasActivated) return;
        setTimeout(init, 0); // this is handle the HARMAN splash screen
        hasActivated = true;
    }

    protected function init():void {
        stage.addEventListener(Event.RESIZE, onResize);
        stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent);
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);

        NativeApplication.nativeApplication.activeWindow.addEventListener(
                NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMiniMaxi);

        webView = WebView.shared();
        webView.addCallback("js_to_as", jsToAsCallback);
        webView.addCallback("forceWebViewFocus", forceWebViewFocus); //for Windows touch - see jsTest.html

        webView.addEventListener(WebViewEvent.ON_PROPERTY_CHANGE, onPropertyChange);
        webView.addEventListener(WebViewEvent.ON_FAIL, onFail);
        webView.addEventListener(WebViewEvent.ON_DOWNLOAD_PROGRESS, onDownloadProgress);
        webView.addEventListener(WebViewEvent.ON_DOWNLOAD_COMPLETE, onDownloadComplete);
        webView.addEventListener(WebViewEvent.ON_URL_BLOCKED, onUrlBlocked);
        webView.addEventListener(WebViewEvent.ON_POPUP_BLOCKED, onPopupBlocked);
        webView.addEventListener(WebViewEvent.ON_PDF_PRINTED, onPdfPrinted); //webView.printToPdf("C:\\path\\to\file.pdf");


        /*webView.addEventListener(KeyboardEvent.KEY_UP, onKeyUp); //KeyboardEvent of webview captured
        webView.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown); //KeyboardEvent of webview captured*/

        var settings:Settings = new Settings();
        settings.popup.behaviour = Behaviour.NEW_WINDOW;  //Behaviour.BLOCK //Behaviour.SAME_WINDOW //Behaviour.REPLACE
        settings.popup.dimensions.width = 600;
        settings.popup.dimensions.height = 800;
        settings.persistRequestHeaders = true;

        //only use settings.userAgent if you are running your own site.
        //google.com for eg displays different sites based on user agent
        //settings.userAgent = "WebViewANE";

        settings.cacheEnabled = true;
        settings.enableDownloads = true;
        settings.contextMenu.enabled = true; //enable/disable right click
        settings.useTransparentBackground = true;

        // See https://github.com/cefsharp/CefSharp/blob/master/CefSharp.Example/CefExample.cs#L37 for more examples
        settings.cef.commandLineArgs.push({
            key: "disable-direct-write",
            value: "1"
        });
        settings.cef.enablePrintPreview = true;
        settings.cef.userDataPath = File.applicationStorageDirectory.nativePath;
        settings.cef.logSeverity = LogSeverity.DISABLE;

        // settings.urlWhiteList.push("html5test.com", "macromedia.","google.", "YouTUBE.", "adobe.com", "chrome-devtools://"); //to restrict urls - simple string matching
        // settings.urlBlackList.push(".pdf");

        var viewPort:Rectangle = new Rectangle(0, 90, _appWidth, _appHeight - 140);

        // trace(os.isWindows, os.majorVersion, os.minorVersion, os.buildVersion);

        webView.init(stage, viewPort, new URLRequest("https://html5test.com"), settings, 1.0, 0xFFF1F1F1);
        //webView.init(stage, viewPort, null, settings, 1.0, 0xFFF1F1F1); // when using loadHTMLString
        webView.visible = true;
        webView.injectScript("function testInject(){console.log('yo yo')}");

        /*trace("loading html");
         webView.loadHTMLString('<!DOCTYPE html>' +
         '<html>' +
         '<head><meta charset="UTF-8">' +
         '<title>Mocked HTML file 1</title>' +
         '</head>' +
         '<body bgColor="#33FF00">' + //must give the body a bg color otherwise it loads black
         '<p>with UTF-8: Björk Guðmundsdóttir Sinéad O’Connor 久保田  利伸 Михаил Горбачёв Садриддин Айнӣ Tor Åge Bringsværd 章子怡 €</p>' +
         '</body>' +
         '</html>', new URLRequest("http://rendering/"));*/


        backBtn.x = 20;
        backBtn.addEventListener(MouseEvent.CLICK, onBack);

        fwdBtn.x = 80;
        fwdBtn.scaleX = -1;
        fwdBtn.addEventListener(MouseEvent.CLICK, onForward);
        fwdBtn.alpha = backBtn.alpha = 0.4;

        refreshBtn.x = 100;
        refreshBtn.addEventListener(MouseEvent.CLICK, onRefresh);

        cancelBtn.x = 100;
        cancelBtn.addEventListener(MouseEvent.CLICK, onCancel);

        zoomInBtn.x = 980;
        zoomInBtn.addEventListener(MouseEvent.CLICK, onZoomIn);

        zoomOutBtn.x = zoomInBtn.x + 40;
        zoomOutBtn.addEventListener(MouseEvent.CLICK, onZoomOut);

        fullscreenBtn.x = zoomOutBtn.x + 40;
        fullscreenBtn.addEventListener(MouseEvent.CLICK, onFullScreen);

        devToolsBtn.y = fullscreenBtn.y = zoomInBtn.y = zoomOutBtn.y =
                backBtn.y = fwdBtn.y = refreshBtn.y = cancelBtn.y = capureBtn.y = 50;

        devToolsBtn.x = fullscreenBtn.x + 40;
        devToolsBtn.addEventListener(MouseEvent.CLICK, onDevTools);

        jsBtn.x = webBtn.x = devToolsBtn.x + 60;
        jsBtn.y = webBtn.y = 48;

        capureBtn.x = jsBtn.x + 60;

        capureBtn.useHandCursor = backBtn.useHandCursor = fwdBtn.useHandCursor = refreshBtn.useHandCursor = cancelBtn.useHandCursor
                = zoomInBtn.useHandCursor = zoomOutBtn.useHandCursor = devToolsBtn.useHandCursor =
                fullscreenBtn.useHandCursor = webBtn.useHandCursor = jsBtn.useHandCursor = true;

        jsBtn.addEventListener(MouseEvent.CLICK, onJS);
        webBtn.addEventListener(MouseEvent.CLICK, onWeb);
        capureBtn.addEventListener(MouseEvent.CLICK, onCapture);

        webBtn.visible = false;
        cancelBtn.visible = false;

        as_js_as_Btn.addEventListener(MouseEvent.CLICK, onAsJsAsBtn);
        eval_js_Btn.addEventListener(MouseEvent.CLICK, onEvalJsBtn);
        as_js_as_Btn.x = 200;
        eval_js_Btn.x = as_js_as_Btn.x + 200;
        as_js_as_Btn.y = eval_js_Btn.y = 42;
        eval_js_Btn.useHandCursor = as_js_as_Btn.useHandCursor = true;
        as_js_as_Btn.visible = eval_js_Btn.visible = false;

        jsBtn.cacheAsBitmap = capureBtn.cacheAsBitmap = cancelBtn.cacheAsBitmap = webBtn.cacheAsBitmap = true;

        urlInput.addEventListener(Input.ENTER, onUrlEnter);
        urlInput.x = 148;
        urlInput.y = 48;

        progress.scaleX = 0;
        progress.x = 150;
        progress.y = 70;

        statusTxt.x = 12;
        statusTxt.y = _appHeight - 36;

        tabBar.addEventListener(TabEvent.ON_NEW_TAB, onNewTab);
        tabBar.addEventListener(TabEvent.ON_SWITCH_TAB, onSwitchTab);
        tabBar.addEventListener(TabEvent.ON_CLOSE_TAB, onCloseTab);

        addChild(tabBar);
        addChild(statusTxt);
        addChild(backBtn);
        addChild(fwdBtn);
        addChild(refreshBtn);
        addChild(cancelBtn);

        addChild(zoomInBtn);
        addChild(zoomOutBtn);
        addChild(fullscreenBtn);
        addChild(devToolsBtn);

        addChild(capureBtn);
        addChild(jsBtn);
        addChild(webBtn);

        addChild(as_js_as_Btn);
        addChild(eval_js_Btn);
        addChild(urlInput);
        addChild(progress);
    }

    private function onEvalJsBtn(event:MouseEvent):void {
        //this is without a callback
        webView.evaluateJavascript('document.getElementsByTagName("body")[0].style.backgroundColor = "yellow";');

        //this is with a callback
        //webView.evaluateJavascript("document.getElementById('output').innerHTML;", onJsEvaluated)
    }

    private function onAsJsAsBtn(event:MouseEvent):void {
        webView.callJavascriptFunction("as_to_js", asToJsCallback, 1, "é", 77);

        // this is how to use without a callback
        // webView.callJavascriptFunction("console.log",null,"hello console. The is AIR");
    }

    private function onUrlEnter(event:Event):void {
        webView.load(new URLRequest(urlInput.text));
    }

    private function onCapture(event:MouseEvent):void {
        webView.capture(function (bitmapData:BitmapData):void {
            if (bitmapData) {
                var ba:ByteArray = new ByteArray();
                var encodingOptions:PNGEncoderOptions = new PNGEncoderOptions(true);
                bitmapData.encode(new Rectangle(0, 0, bitmapData.width, bitmapData.height), encodingOptions, ba);
                var file:File = File.desktopDirectory.resolvePath("webViewANE_capture.png");
                var fs:FileStream = new FileStream();
                fs.open(file, FileMode.WRITE);
                fs.writeBytes(ba);
                fs.close();
                trace("webViewANE_capture.png written to desktop")
            }

        }, new Rectangle(100, 100, 400, 200));
    }

    private function onWeb(event:MouseEvent):void {
        jsBtn.visible = true;
        webBtn.visible = false;
        progress.visible = true;
        urlInput.visible = true;
        as_js_as_Btn.visible = eval_js_Btn.visible = false;
        webView.load(new URLRequest("http://www.adobe.com"));
    }

    private function onJS(event:MouseEvent):void {
        jsBtn.visible = false;
        webBtn.visible = true;
        progress.visible = false;
        urlInput.visible = false;
        as_js_as_Btn.visible = eval_js_Btn.visible = true;
        var localHTML:File = File.applicationDirectory.resolvePath("jsTest.html");
        if (localHTML.exists) {
            webView.loadFileURL(localHTML.nativePath, File.applicationDirectory.nativePath);
        }
    }

    private function onDevTools(event:MouseEvent):void {
        webView.showDevTools(); //webView.closeDevTools();
    }

    private function onFullScreen(event:MouseEvent):void {
        onFullScreenApp();
    }

    private function onZoomOut(event:MouseEvent):void {
        webView.zoomOut();
    }

    private function onZoomIn(event:MouseEvent):void {
        webView.zoomIn();
    }

    private function onCancel(event:MouseEvent):void {
        webView.stopLoading();
    }

    private function onRefresh(event:MouseEvent):void {
        cancelBtn.visible = true;
        refreshBtn.visible = false;
        webView.reload();
    }

    private function loadWithRequestHeaders(event:MouseEvent):void {
        var req:URLRequest = new URLRequest("http://www.google.com");
        req.requestHeaders.push(new URLRequestHeader("Cookie", "BROWSER=WebViewANE;"));
        webView.load(req);
    }

    private function onForward(event:MouseEvent):void {
        webView.goForward();

        /*var obj:BackForwardList = webView.backForwardList();
        trace("back list length",obj.backList.length)
        trace("forward list length",obj.forwardList.length)*/
    }

    private function onBack(event:MouseEvent):void {
        webView.goBack();
    }

    private function onPdfPrinted(event:WebViewEvent):void {
        trace(event);
    }

    private function onKeyDown(event:KeyboardEvent):void {
        trace(event);
    }

    private function onKeyUp(event:KeyboardEvent):void {
        trace(event);
    }

    private function onPopupBlocked(event:WebViewEvent):void {
        stage.dispatchEvent(new MouseEvent(MouseEvent.CLICK)); //this prevents touch getting trapped on Windows
    }

    private function onPropertyChange(event:WebViewEvent):void {
        // read list of tabs and their details like this:
        /*var tabList:Vector.<TabDetails> = webView.tabDetails;
        if (tabList && tabList.length > 0) {
            trace(tabList[webView.currentTab].index, tabList[webView.currentTab].title, tabList[webView.currentTab].url);
        }*/
        switch (event.params.propertyName) {
            case "url":
                if (event.params.tab == webView.currentTab) {
                    urlInput.text = event.params.value;
                }
                break;
            case "title":
                tabBar.setTabTitle(event.params.tab, event.params.value);
                break;
            case "isLoading":
                if (event.params.tab == webView.currentTab) {
                    refreshBtn.visible = !event.params.value;
                    cancelBtn.visible = event.params.value;
                }
                break;
            case "canGoBack":
                if (event.params.tab == webView.currentTab) {
                    backBtn.alpha = event.params.value ? 1.0 : 0.4;
                    backBtn.enabled = event.params.value;
                }
                break;
            case "canGoForward":
                if (event.params.tab == webView.currentTab) {
                    fwdBtn.alpha = event.params.value ? 1.0 : 0.4;
                    fwdBtn.enabled = event.params.value;
                }
                break;
            case "estimatedProgress":
                var p:Number = event.params.value;
                if (event.params.tab == webView.currentTab) {
                    progress.scaleX = p;
                    if (p > 0.99) {
                        TweenLite.to(progress, 0.5, {alpha: 0});
                    } else {
                        progress.alpha = 1;
                    }
                }
                break;
            case "statusMessage":
                if (event.params.tab == webView.currentTab) {
                    statusTxt.text = event.params.value;
                }
                break;
        }
    }

    private function onNewTab(event:TabEvent):void {
        fwdBtn.alpha = backBtn.alpha = 0.4;
        fwdBtn.enabled = backBtn.enabled = false;
        progress.scaleX = 0.0;
        urlInput.text = "";
        webView.addTab(new URLRequest(newTabUrls[tabBar.tabs.length - 2]));
        tabBar.setActiveTab(webView.currentTab);
    }

    private function onSwitchTab(event:TabEvent):void {
        webView.currentTab = event.params.index;
        tabBar.setActiveTab(webView.currentTab);
    }

    private function onCloseTab(event:TabEvent):void {
        webView.closeTab(event.params.index);
        tabBar.closeTab(event.params.index);
        tabBar.setActiveTab(webView.currentTab);
    }

    private static function onUrlBlocked(event:WebViewEvent):void {
        trace(event.params.url, "does not match our urlWhiteList or is on urlBlackList", "tab is:", event.params.tab);
    }

    private function onWindowMiniMaxi(event:NativeWindowDisplayStateEvent):void {
        if (event.afterDisplayState != NativeWindowDisplayState.MINIMIZED) {
            webView.viewPort = new Rectangle(0, 90, _appWidth, _appHeight - 140);
        }
    }

    private static function onDownloadComplete(event:WebViewEvent):void {
        trace(event.params, "complete");
    }

    private static function onDownloadProgress(event:WebViewEvent):void {
        var progress:DownloadProgress = event.params as DownloadProgress;
        trace("progress.id", progress.id);
        trace("progress.url", progress.url);
        trace("progress.percent", progress.percent);
        trace("progress.speed", progress.speed);
        trace("progress.bytesLoaded", progress.bytesLoaded);
        trace("progress.bytesTotal", progress.bytesTotal);
    }

    private function onJsEvaluated(jsResult:JavascriptResult):void {
        trace("Evaluate JS -> AS reached WebViewANESample.as");
        trace("jsResult.error:", jsResult.error);
        trace("jsResult.result:", jsResult.result);
        trace("jsResult.message:", jsResult.message);
        trace("jsResult.success:", jsResult.success);
    }

    public function forceWebViewFocus(asCallback:ActionscriptCallback):void {
        webView.focus();
    }

    public function jsToAsCallback(asCallback:ActionscriptCallback):void {
        trace("JS -> AS reached WebViewANESample.as");
        trace("asCallback.args", asCallback.args);
        trace("asCallback.functionName", asCallback.functionName);
        trace("asCallback.callbackName", asCallback.callbackName);

        if (asCallback.args && asCallback.args.length > 0) {
            var paramA:int = asCallback.args[0] + 33;
            var paramB:String = asCallback.args[1].replace("I am", "You are");
            var paramC:Boolean = !asCallback.args[2];

            trace("paramA", paramA);
            trace("paramB", paramB);
            trace("paramC", paramC);
            trace("we have a callbackName")
        }

        if (asCallback.callbackName) { //if we have a callbackName it means we have a further js call to make
            webView.callJavascriptFunction(asCallback.callbackName, null, paramA, paramB, paramC);
        }

    }

    public static function asToJsCallback(jsResult:JavascriptResult):void {
        trace("asToJsCallback");
        trace("jsResult.error", jsResult.error);
        trace("jsResult.result", jsResult.result);
        trace("jsResult.message", jsResult.message);
        trace("jsResult.success", jsResult.success);
        var testObject:Object = JSON.parse(jsResult.result);
        trace(testObject);
    }

    private static function onFail(event:WebViewEvent):void {
        trace(event.params.url);
        trace(event.params.errorCode);
        trace(event.params.errorText);
        if (event.params.hasOwnProperty("tab")) {
            trace(event.params.tab);
        }
    }

    public function onFullScreenApp():void {
        if (stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
            stage.displayState = StageDisplayState.NORMAL;
            _appWidth = 1280;
            _appHeight = 800;
        } else {
            _appWidth = Capabilities.screenResolutionX;
            _appHeight = Capabilities.screenResolutionY;
            stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
        }
    }

    private function onFullScreenEvent(event:FullScreenEvent):void {
        if (webView) {
            webView.viewPort = new Rectangle(0, 90, _appWidth, _appHeight - 140);
        }
    }

    public function updateWebViewOnResize():void {
        if (webView) {
            webView.viewPort = new Rectangle(0, 90, _appWidth, _appHeight - 140);
        }
    }

    private function onResize(e:Event):void {
        _appWidth = this.stage.stageWidth;
        _appHeight = this.stage.stageHeight;
        updateWebViewOnResize();
    }

    /**
     * It's very important to call WebView.dispose(); when the app is exiting.
     */
    private function onExiting(event:Event):void {
        WebView.dispose();
        FreSwift.dispose();
        FreSharp.dispose();
    }


}
}