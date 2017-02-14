/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

package {
import com.tuarua.WebViewANE;
import com.tuarua.webview.ActionscriptCallback;
import com.tuarua.webview.BackForwardList;
import com.tuarua.webview.BackForwardListItem;
import com.tuarua.webview.DownloadProgress;
import com.tuarua.webview.JavascriptResult;
import com.tuarua.webview.Settings;
import com.tuarua.webview.WebViewEvent;

import flash.desktop.NativeApplication;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.text.TextFieldType;

import events.FormEvent;

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

import views.forms.Input;


public class StarlingRoot extends Sprite {
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

    private var as_js_as_Btn:Image = new Image(Assets.getAtlas().getTexture("as-js-as-btn"));
    private var eval_js_Btn:Image = new Image(Assets.getAtlas().getTexture("eval-js-btn"));

    private var titleTxt:TextField;
    private var statusTxt:TextField;
    private var urlInput:Input;
    private var progress:Quad = new Quad(800, 2, 0x00A3D9);
    private var currentZoom:Number = 1.0;
    private var _appWidth:uint = 1280;
    private var _appHeight:uint = 800;
    private var isDevToolsShowing:Boolean = false;

    public function StarlingRoot() {
        super();
        TextField.registerCompositor(Fonts.getFont("fira-sans-semi-bold-13"), "Fira Sans Semi-Bold 13");

    }

    public function start():void {


        WebViewANESample.target.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent);
        NativeApplication.nativeApplication.addEventListener(flash.events.Event.EXITING, onExiting);

        if (!webView.isSupported) {
            return;
        }

        webView.addCallback("js_to_as", jsToAsCallback);
        webView.addEventListener(WebViewEvent.ON_PROPERTY_CHANGE, onPropertyChange);
        webView.addEventListener(WebViewEvent.ON_FAIL, onFail);
        webView.addEventListener(WebViewEvent.ON_DOWNLOAD_PROGRESS, onDownloadProgress);
        webView.addEventListener(WebViewEvent.ON_DOWNLOAD_COMPLETE, onDownloadComplete);
        webView.addEventListener(WebViewEvent.ON_ESC_KEY, onEscKey);

        var settings:Settings = new Settings();
        settings.userAgent = "WebViewANE";

        // See https://github.com/cefsharp/CefSharp/blob/master/CefSharp.Example/CefExample.cs#L37 for more examples
        //settings.CefCommandLineArgs.Add("disable-direct-write", "1");
        //Disables the DirectWrite font rendering system on windows.
        //Possibly useful when experiencing blury fonts.

        var kvp:Object = {};
        kvp.key = "disable-direct-write";
        kvp.value = "1";
        settings.cef.commandLineArgs.push(kvp);

        webView.setBackgroundColor(0xF1F1F1);

        webView.init("http://www.adobe.com/", 0, 90, _appWidth, _appHeight - 140, settings);
        webView.addToStage(); // webView.removeFromStage();
        webView.injectScript("function testInject(){console.log('yo yo')}");

        /*
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
         */


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


        devToolsBtn.y = fullscreenBtn.y = zoomInBtn.y = zoomOutBtn.y = backBtn.y
                = backBtn.y = fwdBtn.y = refreshBtn.y = cancelBtn.y = 50;


        devToolsBtn.x = fullscreenBtn.x + 40;
        devToolsBtn.addEventListener(TouchEvent.TOUCH, onDevTools);


        jsBtn.x = webBtn.x = devToolsBtn.x + 60;
        jsBtn.y = webBtn.y = 48;

        backBtn.useHandCursor = fwdBtn.useHandCursor = refreshBtn.useHandCursor = cancelBtn.useHandCursor
                = zoomInBtn.useHandCursor = zoomOutBtn.useHandCursor = devToolsBtn.useHandCursor =
                fullscreenBtn.useHandCursor = webBtn.useHandCursor = jsBtn.useHandCursor = true;

        jsBtn.addEventListener(TouchEvent.TOUCH, onJS);
        webBtn.addEventListener(TouchEvent.TOUCH, onWeb);

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


        titleTxt = new TextField(1280, 20, "");
        titleTxt.format = tf;

        titleTxt.batchable = true;
        titleTxt.touchable = false;
        titleTxt.y = 20;

        statusTxt = new TextField(1280, 20, "");
        statusTxt.format = tf;
        statusTxt.format.horizontalAlign = Align.LEFT;
        statusTxt.batchable = true;
        statusTxt.touchable = false;

        statusTxt.x = 12;
        statusTxt.y = _appHeight - 24;


        addChild(titleTxt);
        addChild(statusTxt);
        addChild(backBtn);
        addChild(fwdBtn);
        addChild(refreshBtn);
        addChild(cancelBtn);

        addChild(zoomInBtn);
        addChild(zoomOutBtn);
        addChild(fullscreenBtn);
        if (Capabilities.os.toLowerCase().indexOf("windows") == 0)
            addChild(devToolsBtn);

        addChild(jsBtn);
        addChild(webBtn);

        addChild(as_js_as_Btn);
        addChild(eval_js_Btn);

        addChild(urlInput);

        addChild(progress);

    }

    private function onEscKey(event:WebViewEvent):void {
        trace(event);
        if (WebViewANESample.target.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
            WebViewANESample.target.stage.displayState = StageDisplayState.NORMAL;
            _appWidth = 1280;
            _appHeight = 800;
        }
    }

    private function onDownloadComplete(event:WebViewEvent):void {
        trace(event.params,"complete");
    }

    private function onDownloadProgress(event:WebViewEvent):void {
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
            webView.callJavascriptFunction("as_to_js", asToJsCallback, 1, "a", 77);

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
                webView.loadFileURL("file://" + localHTML.nativePath, "file://" + File.applicationDirectory.nativePath);
            }
        }
    }

    private function onDevTools(event:TouchEvent):void {
        var touch:Touch = event.getTouch(devToolsBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            isDevToolsShowing = !isDevToolsShowing;
            if (isDevToolsShowing) {
                webView.showDevTools();
            } else {
                webView.closeDevTools();
            }
        }
    }

    private function onPropertyChange(event:WebViewEvent):void {
        //trace(event.params,"has changed: ");
        switch (event.params) {
            case "url":
                urlInput.text = webView.url;
                break;
            case "title":
                titleTxt.text = webView.title;
                break;
            case "isLoading":
                refreshBtn.visible = !webView.isLoading;
                cancelBtn.visible = webView.isLoading;
                break;
            case "canGoBack":
                backBtn.alpha = webView.canGoBack ? 1.0 : 0.4;
                backBtn.touchable = webView.canGoBack;
                break;
            case "canGoForward":
                fwdBtn.alpha = webView.canGoForward ? 1.0 : 0.4;
                fwdBtn.touchable = webView.canGoForward;
                break;
            case "estimatedProgress":
                var p:Number = webView.estimatedProgress;
                progress.scaleX = p;
                if (p > 0.99) {
                    Starling.juggler.tween(progress, .5, {
                        transition: Transitions.LINEAR,
                        alpha: 0
                    });
                } else {
                    progress.alpha = 1;
                }
                break;
            case "statusMessage":
                statusTxt.text = webView.statusMessage;
                break;
        }
    }

    private function onZoomOut(event:TouchEvent):void {
        var touch:Touch = event.getTouch(zoomOutBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            currentZoom = currentZoom - .1;
            webView.setMagnification(currentZoom, new Point(0, 0));
        }
    }

    private function onZoomIn(event:TouchEvent):void {
        var touch:Touch = event.getTouch(zoomInBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            currentZoom = currentZoom + .1;
            webView.setMagnification(currentZoom, new Point(0, 0));
        }
    }


    private function onFullScreen(event:TouchEvent):void {
        var touch:Touch = event.getTouch(fullscreenBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            onMaximiseApp();
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
            /*
             var obj:BackForwardList = webView.backForwardList();
             trace()
             trace()
             */
        }
    }

    private function onBack(event:TouchEvent):void {
        var touch:Touch = event.getTouch(backBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.goBack();
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

    public function asToJsCallback(jsResult:JavascriptResult):void {
        trace("asToJsCallback");
        trace("jsResult.error", jsResult.error);
        trace("jsResult.result", jsResult.result);
        trace("jsResult.message", jsResult.message);
        trace("jsResult.success", jsResult.success);
        var testObject:* = jsResult.result;
        trace(testObject);
    }


    private function onFail(event:WebViewEvent):void {
        trace(event.params);
        trace(event.params.url);
        trace(event.params.errorCode);
        trace(event.params.errorText);
    }

    /**
     * It's very important to call webView.shutDown(); when the app is exiting. This cleans up CEF on Windows.
     *
     */
    private function onExiting(event:Event):void {
        webView.shutDown();
    }

    public function onMaximiseApp():void {

        if (WebViewANESample.target.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
            WebViewANESample.target.stage.displayState = StageDisplayState.NORMAL;
            _appWidth = 1280;
            _appHeight = 800;
        } else {
            _appWidth = WebViewANESample.target.stage.fullScreenWidth;
            _appHeight = WebViewANESample.target.stage.fullScreenHeight;

            WebViewANESample.target.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
            WebViewANESample.target.stage.fullScreenSourceRect = new Rectangle(0, 0, _appWidth, _appHeight);
        }
    }

    private function onFullScreenEvent(event:FullScreenEvent):void {
        /*
         !! Needed for OSX, ignored on Windows. Important - must tell the webView  we have gone in/out of fullscreen.
         */
        webView.onFullScreen(event.fullScreen);
        webView.setPositionAndSize(0, 90, _appWidth, _appHeight - 140);
    }

    public function updateWebViewOnResize():void {
        if (webView)
            webView.setPositionAndSize(0, 90, _appWidth, _appHeight - 140);
    }

    public function set appWidth(value:uint):void {
        _appWidth = value;
    }

    public function set appHeight(value:uint):void {
        _appHeight = value;
    }

}
}




