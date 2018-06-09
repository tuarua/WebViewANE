/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

package {
import com.tuarua.CommonDependencies;
import com.tuarua.WebViewANE;
import com.tuarua.utils.os;
import com.tuarua.webview.ActionscriptCallback;
import com.tuarua.webview.DownloadProgress;
import com.tuarua.webview.JavascriptResult;
import com.tuarua.webview.LogSeverity;
import com.tuarua.webview.Settings;
import com.tuarua.webview.WebViewEvent;
import com.tuarua.webview.popup.Behaviour;

import events.FormEvent;
import events.InteractionEvent;

import flash.desktop.NativeApplication;
import flash.display.BitmapData;
import flash.display.NativeWindowDisplayState;
import flash.display.PNGEncoderOptions;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextFieldType;
import flash.utils.ByteArray;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.utils.Align;

import views.TabBar;
import views.forms.Input;

public class StarlingRoot extends Sprite {
    private var commonDependenciesANE:CommonDependencies = new CommonDependencies();//must create before all others
    private var webView:WebViewANE = new WebViewANE();
    private var backBtn:Image = new Image(Assets.getAtlas().getTexture("back-btn"));
    private var fwdBtn:Image = new Image(Assets.getAtlas().getTexture("fwd-btn"));
    private var refreshBtn:Image = new Image(Assets.getAtlas().getTexture("refresh-btn"));
    private var cancelBtn:Image = new Image(Assets.getAtlas().getTexture("cancel-btn"));
    private var zoomInBtn:Image = new Image(Assets.getAtlas().getTexture("zoomin-btn"));
    private var zoomOutBtn:Image = new Image(Assets.getAtlas().getTexture("zoomout-btn"));
    private var fullscreenBtn:Image = new Image(Assets.getAtlas().getTexture("fullscreen-btn"));
    private var devToolsBtn:Image = new Image(Assets.getAtlas().getTexture("dev-tools-btn"));
    private var jsBtn:Image = new Image(Assets.getAtlas().getTexture("js-btn"));
    private var webBtn:Image = new Image(Assets.getAtlas().getTexture("web-btn"));
    private var capureBtn:Image = new Image(Assets.getAtlas().getTexture("capture-btn"));

    private var as_js_as_Btn:Image = new Image(Assets.getAtlas().getTexture("as-js-as-btn"));
    private var eval_js_Btn:Image = new Image(Assets.getAtlas().getTexture("eval-js-btn"));

    private var statusTxt:TextField;
    private var urlInput:Input;
    private var progress:Quad = new Quad(800, 2, 0x00A3D9);
    private var _appWidth:uint = 1280;
    private var _appHeight:uint = 800;
    private var tabBar:TabBar = new TabBar();
    private static const newTabUrls:Vector.<String> = new <String>["https://www.bing.com", "https://www.bbc.co.uk",
        null, "https://www.github.com", "https://forum.starling-framework.org/"];

    public function StarlingRoot() {
        super();
        TextField.registerCompositor(Fonts.getFont("fira-sans-semi-bold-13"), "Fira Sans Semi-Bold 13");
    }

    public function start():void {
        WebViewANESample.target.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent);
        NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);

        NativeApplication.nativeApplication.activeWindow.addEventListener(
                NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMiniMaxi);

        if (!webView.isSupported) {
            return;
        }

        webView.addCallback("js_to_as", jsToAsCallback);
        webView.addCallback("forceWebViewFocus", forceWebViewFocus); //for Windows touch - see jsTest.html

        webView.addEventListener(WebViewEvent.ON_PROPERTY_CHANGE, onPropertyChange);
        webView.addEventListener(WebViewEvent.ON_FAIL, onFail);
        webView.addEventListener(WebViewEvent.ON_DOWNLOAD_PROGRESS, onDownloadProgress);
        webView.addEventListener(WebViewEvent.ON_DOWNLOAD_COMPLETE, onDownloadComplete);
        webView.addEventListener(WebViewEvent.ON_PERMISSION_RESULT, onPermissionResult);
        webView.addEventListener(WebViewEvent.ON_URL_BLOCKED, onUrlBlocked);
        webView.addEventListener(WebViewEvent.ON_POPUP_BLOCKED, onPopupBlocked);
        webView.addEventListener(WebViewEvent.ON_PDF_PRINTED, onPdfPrinted); //webView.printToPdf("C:\\path\\to\file.pdf");


        /*webView.addEventListener(KeyboardEvent.KEY_UP, onKeyUp); //KeyboardEvent of webview captured
        webView.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown); //KeyboardEvent of webview captured*/

        var settings:Settings = new Settings();
        settings.popup.behaviour = Behaviour.NEW_WINDOW;  //Behaviour.BLOCK //Behaviour.SAME_WINDOW
        settings.popup.dimensions.width = 600;
        settings.popup.dimensions.height = 800;

        //only use settings.userAgent if you are running your own site.
        //google.com for eg displays different sites based on user agent
        //settings.userAgent = "WebViewANE";

        settings.cacheEnabled = true;
        settings.enableDownloads = true;
        settings.contextMenu.enabled = true; //enable/disable right click

        // See https://github.com/cefsharp/CefSharp/blob/master/CefSharp.Example/CefExample.cs#L37 for more examples
        settings.cef.commandLineArgs.push({
            key: "disable-direct-write",
            value: "1"
        });
        settings.cef.userDataPath = File.applicationStorageDirectory.nativePath;
        settings.cef.logSeverity = LogSeverity.DISABLE;

        // settings.urlWhiteList.push("macromedia.","google.", "YouTUBE.", "adobe.com", "chrome-devtools://"); //to restrict urls - simple string matching
        // settings.urlBlackList.push(".pdf");

        var viewPort:Rectangle = new Rectangle(0, 90, _appWidth, _appHeight - 140);

        // trace(os.isWindows, os.majorVersion, os.minorVersion, os.buildVersion);

        //webView.init(WebViewANESample.target.stage, viewPort, "https://html5test.com", settings, 1.0, 0xFFF1F1F1, true);
        webView.init(WebViewANESample.target.stage, viewPort, "", settings, 1.0, 0xFFF1F1F1, true); // when using loadHTMLString
        webView.visible = true;
        webView.injectScript("function testInject(){console.log('yo yo')}");

        trace("loading html");
         webView.loadHTMLString('<!DOCTYPE html>' +
         '<html lang="en">' +
         '<head><' +
         'meta charset="UTF-8">' +
         '<title>Mocked HTML file 1</title>' +
         '</head>' +
         '<body bgColor="#33FF00">' + //must give the body a bg color otherwise it loads black
         '<p>I am a test</p>' +
         '</body>' +
         '</html>',"http://rendering/");

        /*trace("loading html");
         webView.loadHTMLString('<!DOCTYPE html>' +
         '<html>' +
         '<head><meta charset="UTF-8">' +
         '<title>Mocked HTML file 1</title>' +
         '</head>' +
         '<body bgColor="#33FF00">' + //must give the body a bg color otherwise it loads black
         '<p>I am a string from C# with UTF-8: Björk Guðmundsdóttir Sinéad O’Connor 久保田  利伸 Михаил Горбачёв Садриддин Айнӣ Tor Åge Bringsværd 章子怡 €</p>' +
         '</body>' +
         '</html>',"http://rendering/");*/


        backBtn.x = 20;
        backBtn.addEventListener(TouchEvent.TOUCH, onBack);

        fwdBtn.x = 60;
        fwdBtn.addEventListener(TouchEvent.TOUCH, onForward);
        fwdBtn.alpha = backBtn.alpha = 0.4;

        refreshBtn.x = 100;
        refreshBtn.addEventListener(TouchEvent.TOUCH, onRefresh);

        cancelBtn.x = 100;
        cancelBtn.addEventListener(TouchEvent.TOUCH, onCancel);

        zoomInBtn.x = 980;
        zoomInBtn.addEventListener(TouchEvent.TOUCH, onZoomIn);

        zoomOutBtn.x = zoomInBtn.x + 40;
        zoomOutBtn.addEventListener(TouchEvent.TOUCH, onZoomOut);

        fullscreenBtn.x = zoomOutBtn.x + 40;
        fullscreenBtn.addEventListener(TouchEvent.TOUCH, onFullScreen);

        devToolsBtn.y = fullscreenBtn.y = zoomInBtn.y = zoomOutBtn.y =
                backBtn.y = fwdBtn.y = refreshBtn.y = cancelBtn.y = capureBtn.y = 50;

        devToolsBtn.x = fullscreenBtn.x + 40;
        devToolsBtn.addEventListener(TouchEvent.TOUCH, onDevTools);

        jsBtn.x = webBtn.x = devToolsBtn.x + 60;
        jsBtn.y = webBtn.y = 48;

        capureBtn.x = jsBtn.x + 60;

        capureBtn.useHandCursor = backBtn.useHandCursor = fwdBtn.useHandCursor = refreshBtn.useHandCursor = cancelBtn.useHandCursor
                = zoomInBtn.useHandCursor = zoomOutBtn.useHandCursor = devToolsBtn.useHandCursor =
                fullscreenBtn.useHandCursor = webBtn.useHandCursor = jsBtn.useHandCursor = true;

        jsBtn.addEventListener(TouchEvent.TOUCH, onJS);
        webBtn.addEventListener(TouchEvent.TOUCH, onWeb);
        capureBtn.addEventListener(TouchEvent.TOUCH, onCapture);

        webBtn.visible = false;
        cancelBtn.visible = false;

        as_js_as_Btn.addEventListener(TouchEvent.TOUCH, onAsJsAsBtn);
        eval_js_Btn.addEventListener(TouchEvent.TOUCH, onEvalJsBtn);
        as_js_as_Btn.x = 200;
        eval_js_Btn.x = as_js_as_Btn.x + 200;
        as_js_as_Btn.y = eval_js_Btn.y = 42;
        eval_js_Btn.useHandCursor = as_js_as_Btn.useHandCursor = true;
        as_js_as_Btn.visible = eval_js_Btn.visible = false;

        var tf:TextFormat = new TextFormat();
        tf.setTo("Fira Sans Semi-Bold 13", 13);
        tf.verticalAlign = Align.TOP;
        tf.color = 0x666666;

        urlInput = new Input(802, "");
        urlInput.type = TextFieldType.INPUT;
        urlInput.enable(true);
        urlInput.freeze(false);
        urlInput.addEventListener(FormEvent.ENTER, onUrlEnter);

        urlInput.x = 148;
        urlInput.y = 48;

        progress.scaleX = 0;
        progress.x = 150;
        progress.y = 70;

        statusTxt = new TextField(1280, 20, "");
        statusTxt.format = tf;
        statusTxt.format.horizontalAlign = Align.LEFT;
        statusTxt.batchable = true;
        statusTxt.touchable = false;

        statusTxt.x = 12;
        statusTxt.y = _appHeight - 24;


        tabBar.addEventListener(InteractionEvent.ON_NEW_TAB, onNewTab);
        tabBar.addEventListener(InteractionEvent.ON_SWITCH_TAB, onSwitchTab);
        tabBar.addEventListener(InteractionEvent.ON_CLOSE_TAB, onCloseTab);
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

    private function onPdfPrinted(event:WebViewEvent):void {
        trace(event);
    }

    private function onKeyDown(event:KeyboardEvent):void {
        trace(event);
    }

    private function onKeyUp(event:KeyboardEvent):void {
        trace(event);
    }

    private static function onPopupBlocked(event:WebViewEvent):void {
        Starling.current.nativeStage.dispatchEvent(new MouseEvent(MouseEvent.CLICK)); //this prevents touch getting trapped on Windows
    }

    private function onNewTab(event:InteractionEvent):void {
        fwdBtn.alpha = backBtn.alpha = 0.4;
        fwdBtn.touchable = backBtn.touchable = false;
        progress.scaleX = 0.0;
        urlInput.text = "";
        webView.addTab(newTabUrls[tabBar.tabs.length - 2]);
        //webView.addTab();
        tabBar.setActiveTab(webView.currentTab);
    }

    private function onSwitchTab(event:InteractionEvent):void {
        webView.currentTab = event.params.index;
        tabBar.setActiveTab(webView.currentTab);
    }

    private function onCloseTab(event:InteractionEvent):void {
        webView.closeTab(event.params.index);
        tabBar.closeTab(event.params.index);
        tabBar.setActiveTab(webView.currentTab);
    }


    private static function onUrlBlocked(event:WebViewEvent):void {
        trace(event.params.url, "does not match our urlWhiteList or is on urlBlackList", "tab is:", event.params.tab);
        //Starling.current.
    }

    private static function onPermissionResult(event:WebViewEvent):void {
        trace("type:", event.params.type);
        trace("granted?", event.params.result);
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

    private function onEvalJsBtn(event:TouchEvent):void {
        var touch:Touch = event.getTouch(eval_js_Btn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {

            //this is without a callback
            webView.evaluateJavascript('document.getElementsByTagName("body")[0].style.backgroundColor = "yellow";');

            //this is with a callback
            //webView.evaluateJavascript("document.getElementById('output').innerHTML;", onJsEvaluated)
        }
    }

    private function onAsJsAsBtn(event:TouchEvent):void {
        var touch:Touch = event.getTouch(as_js_as_Btn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.callJavascriptFunction("as_to_js", asToJsCallback, 1, "é", 77);

            //this is how to use without a callback
            // webView.callJavascriptFunction("console.log",null,"hello console. The is AIR");

        }
    }

    private function onWeb(event:TouchEvent):void {
        var touch:Touch = event.getTouch(webBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            jsBtn.visible = true;
            webBtn.visible = false;

            urlInput.enable(true);
            urlInput.freeze(false);
            urlInput.visible = true;
            progress.visible = true;

            as_js_as_Btn.visible = eval_js_Btn.visible = false;

            webView.load("http://www.adobe.com");
        }
    }

    private function onJS(event:TouchEvent):void {
        var touch:Touch = event.getTouch(jsBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {

            jsBtn.visible = false;
            webBtn.visible = true;

            urlInput.enable(false);
            urlInput.freeze(true);
            urlInput.visible = false;
            progress.visible = false;

            as_js_as_Btn.visible = eval_js_Btn.visible = true;

            var localHTML:File = File.applicationDirectory.resolvePath("jsTest.html");
            if (localHTML.exists) {
                webView.loadFileURL(localHTML.nativePath, File.applicationDirectory.nativePath);
            }
        }
    }

    private function onDevTools(event:TouchEvent):void {
        var touch:Touch = event.getTouch(devToolsBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.showDevTools(); //webView.closeDevTools();
        }
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
                    backBtn.touchable = event.params.value;
                }
                break;
            case "canGoForward":
                if (event.params.tab == webView.currentTab) {
                    fwdBtn.alpha = event.params.value ? 1.0 : 0.4;
                    fwdBtn.touchable = event.params.value;
                }
                break;
            case "estimatedProgress":
                var p:Number = event.params.value;
                if (event.params.tab == webView.currentTab) {
                    progress.scaleX = p;
                    if (p > 0.99) {
                        Starling.juggler.tween(progress, .5, {
                            transition: Transitions.LINEAR,
                            alpha: 0
                        });
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

    private function onZoomOut(event:TouchEvent):void {
        var touch:Touch = event.getTouch(zoomOutBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.zoomOut();
        }
    }

    private function onZoomIn(event:TouchEvent):void {
        var touch:Touch = event.getTouch(zoomInBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.zoomIn();
        }
    }

    private function onFullScreen(event:TouchEvent):void {
        var touch:Touch = event.getTouch(fullscreenBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            onFullScreenApp();
        }
    }

    private function onUrlEnter(event:FormEvent):void {
        webView.load(urlInput.text);
    }

    private function onCancel(event:TouchEvent):void {
        var touch:Touch = event.getTouch(cancelBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.stopLoading();
        }
    }

    private function onForward(event:TouchEvent):void {
        var touch:Touch = event.getTouch(fwdBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.goForward();

            /*var obj:BackForwardList = webView.backForwardList();
            trace("back list length",obj.backList.length)
            trace("forward list length",obj.forwardList.length)*/

        }
    }

    private function onBack(event:TouchEvent):void {
        var touch:Touch = event.getTouch(backBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.goBack();
        }
    }

    private function onCapture(event:TouchEvent):void {
        var touch:Touch = event.getTouch(capureBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
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
    }

    private function onRefresh(event:TouchEvent):void {
        var touch:Touch = event.getTouch(refreshBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            cancelBtn.visible = true;
            refreshBtn.visible = false;
            webView.reload();
        }
    }

    private function onJsEvaluated(jsResult:JavascriptResult):void {
        trace("Evaluate JS -> AS reached StarlingRoot.as");
        trace("jsResult.error:", jsResult.error);
        trace("jsResult.result:", jsResult.result);
        trace("jsResult.message:", jsResult.message);
        trace("jsResult.success:", jsResult.success);
    }

    public function forceWebViewFocus(asCallback:ActionscriptCallback):void {
        webView.focus();
    }

    public function jsToAsCallback(asCallback:ActionscriptCallback):void {
        trace("JS -> AS reached StarlingRoot.as");
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
        var testObject:* = jsResult.result;
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
        if (WebViewANESample.target.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
            WebViewANESample.target.stage.displayState = StageDisplayState.NORMAL;
            _appWidth = 1280;
            _appHeight = 800;
        } else {
            _appWidth = Capabilities.screenResolutionX;
            _appHeight = Capabilities.screenResolutionY;
            WebViewANESample.target.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
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

    public function set appWidth(value:uint):void {
        _appWidth = value;
    }

    public function set appHeight(value:uint):void {
        _appHeight = value;
    }

    /**
     * It's very important to call webView.dispose(); when the app is exiting.
     */
    private function onExiting(event:Event):void {
        webView.dispose();
        commonDependenciesANE.dispose();
    }


}
}




