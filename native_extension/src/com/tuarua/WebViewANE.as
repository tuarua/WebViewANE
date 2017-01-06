package com.tuarua {
import com.tuarua.webview.WebViewEvent;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.system.Capabilities;

public class WebViewANE extends EventDispatcher {
    private static const name:String = "WebViewANE";
    private var extensionContext:ExtensionContext;
    private var isInited:Boolean = false;
    private var _isSupported:Boolean = false;

    public function WebViewANE() {
        initiate();
    }


    protected function initiate():void {
        isInited = true;

        if (Capabilities.os.toLowerCase().indexOf("mac os") > -1) {
            _isSupported = true;
        }

        if (_isSupported) {
            trace("[" + name + "] Initalizing ANE...");
            try {
                extensionContext = ExtensionContext.createExtensionContext("com.tuarua." + name, null);
                extensionContext.addEventListener(StatusEvent.STATUS, gotEvent);
            } catch (e:Error) {
                trace("[" + name + "] ANE Not loaded properly.  Future calls will fail.");
            }
        } else {
            trace("[" + name + "] Can't initialize. Only OSX is supported");
        }

    }

    private function gotEvent(event:StatusEvent):void {
        var pObj:Object;
        switch (event.level) {
            case "TRACE":
                trace(event.code);
                break;
            case WebViewEvent.WEBVIEW_ON_URL_CHANGE:
                dispatchEvent(new WebViewEvent(WebViewEvent.WEBVIEW_ON_URL_CHANGE, JSON.parse(event.code)));
                break;
            case WebViewEvent.WEBVIEW_ON_FINISH:
                dispatchEvent(new WebViewEvent(WebViewEvent.WEBVIEW_ON_FINISH, null));
                break;
            case WebViewEvent.WEBVIEW_ON_START:
                dispatchEvent(new WebViewEvent(WebViewEvent.WEBVIEW_ON_START, null));
                break;
            case WebViewEvent.WEBVIEW_ON_FAIL:
                dispatchEvent(new WebViewEvent(WebViewEvent.WEBVIEW_ON_FAIL, null));
                break;
        }
    }

    public function init(x:int = 0, y:int = 0, width:int = 800, height:int = 600):void {
        if (_isSupported) {
            extensionContext.call("init", x, y, width, height);
            isInited = true;
        }
    }

    public function addToStage():void {
        if (!isInited) {
            trace("You need to init first")
            return;
        }
        if (_isSupported)
            extensionContext.call("addToStage");
    }

    public function load(url:String):void {
        if (!isInited) {
            trace("You need to init first")
            return;
        }
        if (_isSupported)
            extensionContext.call("load", url);
    }

    public function reload():void {
        if (!isInited) {
            trace("You need to init first")
            return;
        }
        if (_isSupported)
            extensionContext.call("reload");
    }


    public function get isSupported():Boolean {
        return _isSupported;
    }

    public function dispose():void {
        if (!extensionContext) {
            trace("[" + name + "] Error. ANE Already in a disposed or failed state...");
            return;
        }
        trace("[" + name + "] Unloading ANE...");
        extensionContext.removeEventListener(StatusEvent.STATUS, gotEvent);
        extensionContext.dispose();
        extensionContext = null;
    }

}
}