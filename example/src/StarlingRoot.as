package {
import com.tuarua.WebViewANE;
import com.tuarua.webview.WebViewEvent;

import flash.desktop.NativeApplication;
import flash.events.Event;

import starling.display.Sprite;

import starling.text.TextField;
import starling.text.TextFormat;
import starling.utils.Align;


public class StarlingRoot extends Sprite {
    private var webView:WebViewANE = new WebViewANE();

    private var holder:Sprite = new Sprite();
    private var urlTxt:TextField;

    public function StarlingRoot() {
        super();
        TextField.registerBitmapFont(Fonts.getFont("fira-sans-semi-bold-13"));
    }

    public function start():void {

        NativeApplication.nativeApplication.addEventListener(flash.events.Event.EXITING, onExiting);

        webView.addEventListener(WebViewEvent.WEBVIEW_ON_URL_CHANGE,onUrlChange);
        webView.addEventListener(WebViewEvent.WEBVIEW_ON_START,onStart);
        webView.addEventListener(WebViewEvent.WEBVIEW_ON_FINISH,onFinish);
        webView.addEventListener(WebViewEvent.WEBVIEW_ON_FAIL,onFail);
        webView.init(0,150,1280,600);
        webView.addToStage();
        webView.load("http://www.adobe.com/");



        var tf:TextFormat = new TextFormat()

        urlTxt = new TextField(1000,200,"url will appear here");
        urlTxt.format.setTo("Fira Sans Semi-Bold 13",13);
        urlTxt.format.horizontalAlign = Align.LEFT;
        urlTxt.format.verticalAlign = Align.TOP;
        urlTxt.format.color = 0x666666;

        urlTxt.batchable = false;
        urlTxt.touchable = false;
        urlTxt.x = 50;
        urlTxt.y = 50;

        addChild(urlTxt);

    }

    private function onFail(event:WebViewEvent):void {
        trace(event);
    }

    private function onFinish(event:WebViewEvent):void {
        trace(event);
    }

    private function onStart(event:WebViewEvent):void {
        trace(event);
    }

    private function onUrlChange(event:WebViewEvent):void {
        var obj:Object = event.params;
        if(obj){
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




