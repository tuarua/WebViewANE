package {
import com.tuarua.WebViewANE;
import com.tuarua.webview.ActionscriptCallback;
import com.tuarua.webview.Settings;
import com.tuarua.webview.WebViewEvent;

import flash.desktop.NativeApplication;
import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.events.KeyboardEvent;
import flash.events.SoftKeyboardEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import flash.text.StageText;
import flash.ui.Keyboard;
import flash.events.Event;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.ResizeEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.text.TextFormat;
import starling.utils.Align;
import starling.utils.AssetManager;

public class StarlingRoot extends Sprite {
    private var backBtn:Image;
    private var fwdBtn:Image;
    private var refreshBtn:Image;
    private var cancelBtn:Image;
    private var jsBtn:Image;
    private var webBtn:Image;

    private var progress:Quad;
    private var inputBG:Image;
    private var urlInput:StageText;
    private var titleTxt:TextField;
    private var webView:WebViewANE;

    public function StarlingRoot() {
    }

    public function start(assets:AssetManager):void {
        NativeApplication.nativeApplication.addEventListener(flash.events.Event.EXITING, onExiting);
        var _assets:AssetManager = assets;

        backBtn = new Image(_assets.getTexture("back-btn"));
        fwdBtn = new Image(_assets.getTexture("fwd-btn"));
        refreshBtn = new Image(_assets.getTexture("refresh-btn"));
        cancelBtn = new Image(_assets.getTexture("cancel-btn"));

        jsBtn = new Image(_assets.getTexture("js-btn"));
        webBtn = new Image(_assets.getTexture("web-btn"));

        backBtn.x = 5;
        backBtn.addEventListener(TouchEvent.TOUCH, onBack);

        fwdBtn.x = backBtn.x + 30;
        fwdBtn.addEventListener(TouchEvent.TOUCH, onForward);

        fwdBtn.alpha = backBtn.alpha = 0.4;

        cancelBtn.x = refreshBtn.x = fwdBtn.x + 30;
        refreshBtn.addEventListener(TouchEvent.TOUCH, onRefresh);

        cancelBtn.addEventListener(TouchEvent.TOUCH, onCancel);

        jsBtn.x = webBtn.x = stage.stageWidth - 40;
        backBtn.y = fwdBtn.y = refreshBtn.y = cancelBtn.y = 35;
        webBtn.y = jsBtn.y = 35;

        jsBtn.addEventListener(TouchEvent.TOUCH, onJS);
        webBtn.addEventListener(TouchEvent.TOUCH, onWeb);

        webBtn.visible = false;
        cancelBtn.visible = false;

        inputBG = new Image(_assets.getTexture("input-bg"));
        inputBG.scale9Grid = new Rectangle(4, 4, 16, 16);
        inputBG.width = stage.stageWidth - 108 - 50;
        inputBG.height = 25;
        inputBG.x = 108;
        inputBG.y = 38;

        inputBG.touchable = false;

        progress = new Quad(inputBG.width - 2, 2, 0x00A3D9); //stage.stageWidth - something
        progress.touchable = false;
        progress.scaleX = 0;
        progress.x = 109;
        progress.y = 60;

        addChild(inputBG);

        addChild(backBtn);
        addChild(fwdBtn);
        addChild(refreshBtn);
        addChild(cancelBtn);
        addChild(jsBtn);
        addChild(webBtn);
        addChild(progress);

        var tf:TextFormat = new TextFormat();
        tf.setTo("Fira Sans", 13);
        tf.verticalAlign = Align.TOP;
        tf.horizontalAlign = Align.CENTER;
        tf.color = 0x666666;
        titleTxt = new TextField(stage.stageWidth - 20, 20, "");
        titleTxt.format = tf;

        titleTxt.batchable = true;
        titleTxt.touchable = false;
        titleTxt.x = 10;
        titleTxt.y = 10;

        addChild(titleTxt);

        webView = new WebViewANE();
        webView.addEventListener(WebViewEvent.ON_PROPERTY_CHANGE, onPropertyChange);
        webView.addEventListener(WebViewEvent.ON_URL_BLOCKED, onUrlBlocked);
        webView.addEventListener(WebViewEvent.ON_FAIL, onUrlFail);

        var settings:Settings = new Settings();
        settings.webkit.allowsInlineMediaPlayback = true;
        settings.webkit.bounces = false;


        //settings.webkit.useZoomGestures = false; //disable pinch zoom iOS
        //settings.android.builtInZoomControls = false; //disable pinch zoom Android

        //settings.urlWhiteList.push("macromedia.", "github.", "google.", "youtube.", "adobe.com", "chrome-devtools://"); //to restrict urls - simple string matching
        //settings.urlBlackList.push(".pdf");

        webView.addCallback("js_to_as", jsToAsCallback);
        var viewPort:Rectangle = new Rectangle(0, 80, stage.stageWidth, (stage.stageHeight - 80));
        webView.init(Starling.current.nativeStage, viewPort, "https://github.com/tuarua/WebViewANE",
                settings, Starling.current.contentScaleFactor, 0xF1F1F1, 0.0);
        webView.visible = true;

        webView.showDevTools();  //open chrome://inspect in Chrome for Android - ignored on iOS

        urlInput = new StageText();

        urlInput.returnKeyLabel = ReturnKeyLabel.GO;
        urlInput.stage = Starling.current.nativeStage;
        urlInput.fontFamily = "FiraSansEmbed";
        urlInput.fontSize = 13 * Starling.current.contentScaleFactor;
        urlInput.color = 0x666666;
        urlInput.text = "http://github.com/tuarua/WebViewANE";
        urlInput.softKeyboardType = SoftKeyboardType.URL;
        urlInput.addEventListener(KeyboardEvent.KEY_DOWN, onUrlEnter); //KEY_DOWN is important, KEY_UP causes issues in AIR 26 on Android
        urlInput.viewPort = new Rectangle((inputBG.x + 5) * Starling.current.contentScaleFactor,
                (inputBG.y + 4) * Starling.current.contentScaleFactor,
                (inputBG.width - 10) * Starling.current.contentScaleFactor,
                (inputBG.height - 3) * Starling.current.contentScaleFactor);


        stage.addEventListener(Event.RESIZE, onResize);

        copyHTMLFiles();
    }

    private function onUrlFail(event:WebViewEvent):void {
        var error:Object = event.params;
        trace("error.url", error.url);
        trace("error.errorCode", error.errorCode);
        trace("error.errorText", error.errorText);
    }

    private static function copyHTMLFiles():void {

        var inFile1:File = File.applicationDirectory.resolvePath("jsTest.html");
        var inStream1:FileStream = new FileStream();
        inStream1.open(inFile1, FileMode.READ);
        var fileContents1:String = inStream1.readUTFBytes(inStream1.bytesAvailable);
        inStream1.close();

        var outFile1:File = File.applicationStorageDirectory.resolvePath("jsTest.html");
        var outStream1:FileStream = new FileStream();
        outStream1.open(outFile1, FileMode.WRITE);
        outStream1.writeUTFBytes(fileContents1);
        outStream1.close();

        var inFile2:File = File.applicationDirectory.resolvePath("localTest.html");
        var inStream2:FileStream = new FileStream();
        inStream2.open(inFile2, FileMode.READ);
        var fileContents2:String = inStream2.readUTFBytes(inStream2.bytesAvailable);
        inStream2.close();

        var outFile2:File = File.applicationStorageDirectory.resolvePath("localTest.html");
        var outStream2:FileStream = new FileStream();
        outStream2.open(outFile2, FileMode.WRITE);
        outStream2.writeUTFBytes(fileContents2);
        outStream2.close();
    }

    private function onWeb(event:TouchEvent):void {
        var touch:Touch = event.getTouch(webBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            jsBtn.visible = true;
            webBtn.visible = false;
            progress.visible = true;
            webView.load("http://www.adobe.com");
        }
    }

    private function onJS(event:TouchEvent):void {
        var touch:Touch = event.getTouch(jsBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            jsBtn.visible = false;
            webBtn.visible = true;
            progress.visible = false;
            var localHTML1:File = File.applicationStorageDirectory.resolvePath("jsTest.html");
            if (localHTML1.exists) {
                webView.loadFileURL("file://" + encodeURI(localHTML1.nativePath), "file://" + encodeURI(File.applicationStorageDirectory.nativePath));
            }
        }
    }

    private function onCancel(event:TouchEvent):void {
        var touch:Touch = event.getTouch(cancelBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.stopLoading();
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

    private function onForward(event:TouchEvent):void {
        var touch:Touch = event.getTouch(fwdBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.goForward();


            /*
             var obj:BackForwardList = webView.backForwardList();
             trace("back list length",obj.backList.length)
             trace("forward list length",obj.forwardList.length)
             */
        }
    }

    private function onBack(event:TouchEvent):void {
        var touch:Touch = event.getTouch(backBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            webView.goBack();
        }
    }

    private function onUrlEnter(event:KeyboardEvent):void {
        event.preventDefault(); //Android needs this. We need to programmatically close the keyboard then.
        urlInput.stage.focus = null;
        if (event.keyCode == Keyboard.ENTER) {
            webView.load(urlInput.text);
        }
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

    private static function onUrlBlocked(event:WebViewEvent):void {
        trace(event.params.url, "does not match our urlWhiteList or is on urlBlackList");
    }

    private function onPropertyChange(event:WebViewEvent):void {
        // trace("");
        //trace(event.params.propertyName, "has changed:", "to", event.params.value);
        // trace("------");

        switch (event.params.propertyName) {
            case "url":
                urlInput.text = event.params.value;
                break;
            case "title":
                titleTxt.text = event.params.value;
                break;
            case "isLoading":
                refreshBtn.visible = !event.params.value;
                cancelBtn.visible = event.params.value;
                break;
            case "canGoBack":
                backBtn.alpha = event.params.value ? 1.0 : 0.4;
                backBtn.touchable = event.params.value;
                break;
            case "canGoForward":
                fwdBtn.alpha = event.params.value ? 1.0 : 0.4;
                fwdBtn.touchable = event.params.value;
                break;
            case "estimatedProgress":
                var p:Number = event.params.value;
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
        }
    }

    public function onResize(event:ResizeEvent):void {

        var current:Starling = Starling.current;
        var scale:Number = current.contentScaleFactor;

        stage.stageWidth = event.width / scale;
        stage.stageHeight = event.height / scale;

        current.viewPort.width = stage.stageWidth * scale;
        current.viewPort.height = stage.stageHeight * scale;

        jsBtn.x = webBtn.x = stage.stageWidth - 40;
        inputBG.width = stage.stageWidth - 108 - 50;


        progress.width = inputBG.width - 2;

        //trace("onResize", "stage.stageWidth:", stage.stageWidth);
        //trace("onResize", "progress.width:", progress.width);

        webView.viewPort = new Rectangle(0, 80, stage.stageWidth, stage.stageHeight - 80);

        titleTxt.width = stage.stageWidth - 20;
        urlInput.viewPort = new Rectangle((inputBG.x + 5) * Starling.current.contentScaleFactor,
                (inputBG.y + 4) * Starling.current.contentScaleFactor,
                (inputBG.width - 10) * Starling.current.contentScaleFactor,
                (inputBG.height - 3) * Starling.current.contentScaleFactor);

    }

    /**
     * It's very important to call webView.dispose(); when the app is exiting.
     */
    private function onExiting(event:flash.events.Event):void {
        webView.dispose();
    }
}
}