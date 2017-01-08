/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */

package {
import com.tuarua.WebViewANE;
import com.tuarua.webview.BackForwardList;
import com.tuarua.webview.BackForwardListItem;
import com.tuarua.webview.WebViewEvent;

import events.FormEvent;

import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.filesystem.File;
import flash.geom.Point;
import flash.text.TextFieldType;

import starling.animation.Transitions;

import starling.animation.Tween;
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
    private var titleTxt:TextField;
    private var urlInput:Input;
    private var progress:Quad = new Quad(800, 2, 0x00A3D9)
    private var currentZoom:Number = 1.0;

    public function StarlingRoot() {
        super();
        TextField.registerBitmapFont(Fonts.getFont("fira-sans-semi-bold-13"));
    }

    public function start():void {

        NativeApplication.nativeApplication.addEventListener(flash.events.Event.EXITING, onExiting);

        if (!webView.isSupported) return;

        webView.addEventListener(WebViewEvent.ON_URL_CHANGE, onUrlChange);
        webView.addEventListener(WebViewEvent.ON_START, onStart);
        webView.addEventListener(WebViewEvent.ON_FINISH, onFinish);
        webView.addEventListener(WebViewEvent.ON_FAIL, onFail);
        webView.addEventListener(WebViewEvent.ON_PROGRESS, onProgress);
        webView.addEventListener(WebViewEvent.ON_JAVASCRIPT_RESULT, onJavascriptResult);
        webView.addEventListener(WebViewEvent.ON_PAGE_TITLE, onPageTitle);
        webView.addEventListener(WebViewEvent.ON_BACK_FORWARD_UPDATE, onBackForwardUpdate);
        webView.init(0, 90, 1280, 660);
        webView.addToStage();



        // webView.removeFromStage();

        webView.load("http://www.adobe.com/");

        /*
        //load a HTML string
        webView.loadHTMLString('<!DOCTYPE html>' +
                '<html lang="en">' +
                '<head><' +
                'meta charset="UTF-8">' +
                '<title>Mocked HTML file</title>' +
                '</head>' +
                '<body>' +
                '<p>I am a test</p>' +
                '</body>' +
                '</html>');
                */

        /*
        //load a local file
        var localHTML:File = File.applicationDirectory.resolvePath("localTest.html");
        if(localHTML.exists){
            webView.loadFileURL("file://" + localHTML.nativePath,"file://" + File.applicationDirectory.nativePath);
        }
        */

        webView.evaluateJavaScript("navigator.userAgent");

        backBtn.x = 20;
        backBtn.addEventListener(TouchEvent.TOUCH,onBack);

        fwdBtn.x = 60;
        fwdBtn.addEventListener(TouchEvent.TOUCH,onForward);

        fwdBtn.alpha = backBtn.alpha = 0.4;

        refreshBtn.x = 100;
        refreshBtn.addEventListener(TouchEvent.TOUCH,onRefresh);

        cancelBtn.x = 100;
        cancelBtn.addEventListener(TouchEvent.TOUCH,onCancel);

        zoomInBtn.x = 980;
        zoomInBtn.addEventListener(TouchEvent.TOUCH,onZoomIn);

        zoomOutBtn.x = zoomInBtn.x + 40;
        zoomOutBtn.addEventListener(TouchEvent.TOUCH,onZoomOut);

        zoomInBtn.y = zoomOutBtn.y = backBtn.y = backBtn.y = fwdBtn.y = refreshBtn.y = cancelBtn.y = 50;
        cancelBtn.visible = false;

        var tf:TextFormat = new TextFormat();
        tf.setTo("Fira Sans Semi-Bold 13", 13);
        tf.verticalAlign = Align.TOP;
        tf.color = 0x666666;


        urlInput = new Input(802,"");
        urlInput.type = TextFieldType.INPUT;
        urlInput.enable(true);
        urlInput.freeze(false);
        urlInput.addEventListener(FormEvent.ENTER,onUrlEnter)

        urlInput.x = 148;
        urlInput.y = 48;

        progress.x = 150;
        progress.y = 70;


        titleTxt = new TextField(1280, 20, "");
        titleTxt.format = tf;
        titleTxt.format.horizontalAlign = Align.CENTER;
        titleTxt.batchable = true;
        titleTxt.touchable = false;
        titleTxt.y = 20;

        addChild(titleTxt);
        addChild(backBtn);
        addChild(fwdBtn);
        addChild(refreshBtn);
        addChild(cancelBtn);

        addChild(zoomInBtn);
        addChild(zoomOutBtn);

        addChild(urlInput);

        addChild(progress);

    }

    private function onBackForwardUpdate(event:WebViewEvent):void {
        backBtn.alpha = webView.canGoBackward() ? 1.0 : 0.4;
        fwdBtn.alpha = webView.canGoForward() ? 1.0 : 0.4;
        backBtn.touchable = webView.canGoBackward()
        fwdBtn.touchable = webView.canGoForward()
    }

    private function onZoomOut(event:TouchEvent):void {
        var touch:Touch = event.getTouch(zoomOutBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            currentZoom = currentZoom - .1
            webView.setMagnification(currentZoom,new Point(0,0));
        }
    }

    private function onZoomIn(event:TouchEvent):void {
        var touch:Touch = event.getTouch(zoomInBtn);
        if (touch != null && touch.phase == TouchPhase.ENDED) {
            currentZoom = currentZoom + .1
            webView.setMagnification(currentZoom,new Point(0,0));
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


    private function onProgress(event:WebViewEvent):void {
        var obj:Object = event.params;
        if (obj) {
            progress.scaleX = obj.value;
            if (obj.value > 0.99) {
                var tween:Tween;
                Starling.juggler.tween(progress, .5, {
                    transition: Transitions.LINEAR,
                    alpha: 0
                });
            } else {
                progress.alpha = 1;
            }
        }
    }

    private function onJavascriptResult(event:WebViewEvent):void {
        var obj:Object = event.params;
        if (obj) {
            trace("onJavascriptResult result:", obj.result,"error:",obj.error);
        }
    }

    private function onFail(event:WebViewEvent):void {
        trace(event);
    }

    private function onFinish(event:WebViewEvent):void {
        var obj:Object = event.params;
        if (obj) {
            titleTxt.text = obj.title;
        }
        refreshBtn.visible = true;
        cancelBtn.visible = false;
    }

    private function onPageTitle(event:WebViewEvent):void {
        var obj:Object = event.params;
        if (obj) {
            titleTxt.text = obj.title;
        }
    }

    private function onStart(event:WebViewEvent):void {
        refreshBtn.visible = false;
        cancelBtn.visible = true;
    }

    private function onUrlChange(event:WebViewEvent):void {
        var obj:Object = event.params;
        if (obj) {
            urlInput.text = obj.url;
        }
    }


    private function onExiting(event:Event):void {
        trace("exiting app");
        webView.dispose();
    }

}
}




