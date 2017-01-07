package {
import com.tuarua.WebViewANE;
import com.tuarua.webview.WebViewEvent;

import flash.desktop.NativeApplication;
import flash.events.Event;

import starling.animation.Transitions;

import starling.animation.Tween;
import starling.core.Starling;

import starling.display.Quad;

import starling.display.Sprite;

import starling.text.TextField;
import starling.text.TextFormat;
import starling.utils.Align;


public class StarlingRoot extends Sprite {
    private var webView:WebViewANE = new WebViewANE();

    private var holder:Sprite = new Sprite();
    private var urlTxt:TextField;
    private var titleTxt:TextField;
    private var progress:Quad = new Quad(1280, 3, 0xA3D900)

    public function StarlingRoot() {
        super();
        TextField.registerBitmapFont(Fonts.getFont("fira-sans-semi-bold-13"));
    }

    public function start():void {

        NativeApplication.nativeApplication.addEventListener(flash.events.Event.EXITING, onExiting);

        webView.addEventListener(WebViewEvent.ON_URL_CHANGE, onUrlChange);
        webView.addEventListener(WebViewEvent.ON_START, onStart);
        webView.addEventListener(WebViewEvent.ON_FINISH, onFinish);
        webView.addEventListener(WebViewEvent.ON_FAIL, onFail);
        webView.addEventListener(WebViewEvent.ON_PROGRESS, onProgress);
        webView.addEventListener(WebViewEvent.ON_JAVASCRIPT_RESULT, onJavascriptResult);
        webView.addEventListener(WebViewEvent.ON_PAGE_TITLE, onPageTitle);
        webView.init(0, 150, 1280, 600);
        webView.addToStage();

        // webView.removeFromStage();

        webView.load("http://www.adobe.com/");
        webView.evaluateJavaScript("navigator.userAgent");

        var tf:TextFormat = new TextFormat();
        tf.setTo("Fira Sans Semi-Bold 13", 13);
        tf.verticalAlign = Align.TOP;
        tf.color = 0x666666;
        urlTxt = new TextField(1000, 200, "");
        urlTxt.format = tf;
        urlTxt.format.horizontalAlign = Align.LEFT;

        urlTxt.batchable = true;
        urlTxt.touchable = false;
        urlTxt.x = 50;
        urlTxt.y = 80;

        progress.y = 145;


        titleTxt = new TextField(1280, 20, "");
        titleTxt.format = tf;
        titleTxt.format.horizontalAlign = Align.CENTER;
        titleTxt.batchable = true;
        titleTxt.touchable = false;
        titleTxt.y = 20;

        addChild(titleTxt);
        addChild(urlTxt);


        addChild(progress);

    }


    private function onProgress(event:WebViewEvent):void {
        var obj:Object = event.params;
        if (obj) {
            progress.scaleX = obj.value;
            if (obj.value > 0.99) {
                //fade out the load bar //TODO
                var tween:Tween;
                Starling.juggler.tween(progress, .5, {
                    transition: Transitions.LINEAR,
                    alpha: 0
                });
            } else {
                progress.alpha = 1;
            }
            trace("Progress:", obj.value);
        }
    }

    private function onJavascriptResult(event:WebViewEvent):void {
        var obj:Object = event.params;
        if (obj) {
            trace("onJavascriptResult result:", obj.result);
            trace("onJavascriptResult error:", obj.error);
        }
    }

    private function onFail(event:WebViewEvent):void {
        trace(event);
    }

    private function onFinish(event:WebViewEvent):void {
        trace(event);
        var obj:Object = event.params;
        if (obj) {
            titleTxt.text = obj.title;
        }

    }

    private function onPageTitle(event:WebViewEvent):void {
        trace(event);
        var obj:Object = event.params;
        if (obj) {
            titleTxt.text = obj.title;
        }
    }

    private function onStart(event:WebViewEvent):void {
        trace(event);

    }

    private function onUrlChange(event:WebViewEvent):void {
        var obj:Object = event.params;
        if (obj) {
            urlTxt.text = obj.url;
            // trace("url changed to:",obj.url);
        }
    }


    private function onExiting(event:Event):void {
        trace("exiting app");
        webView.dispose();
    }

}
}




