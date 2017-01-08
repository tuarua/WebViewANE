/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */
package com.tuarua {
import com.tuarua.webview.BackForwardList;
import com.tuarua.webview.WebViewEvent;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.geom.Point;
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
                _isSupported = extensionContext.call("isSupported");
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
            case WebViewEvent.ON_URL_CHANGE:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_URL_CHANGE, JSON.parse(event.code)));
                break;
            case WebViewEvent.ON_FINISH:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_FINISH, JSON.parse(event.code)));
                break;
            case WebViewEvent.ON_START:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_START, JSON.parse(event.code)));
                break;
            case WebViewEvent.ON_FAIL:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_FAIL, JSON.parse(event.code)));
                break;
            case WebViewEvent.ON_JAVASCRIPT_RESULT:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_JAVASCRIPT_RESULT, JSON.parse(event.code)));
                break;
            case WebViewEvent.ON_PROGRESS:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_PROGRESS, JSON.parse(event.code)));
                break;
            case WebViewEvent.ON_PAGE_TITLE:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_PAGE_TITLE, JSON.parse(event.code)));
                break;
            case WebViewEvent.ON_BACK_FORWARD_UPDATE:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_BACK_FORWARD_UPDATE, null));
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
        if (safetyCheck())
            extensionContext.call("addToStage");
    }

    public function isLoading():Boolean {
        if (safetyCheck())
            return extensionContext.call("isLoading");
        return false;
    }

    public function canGoBackward():Boolean {
        if (safetyCheck())
            return extensionContext.call("canGoBack");
        return false;
    }

    public function canGoForward():Boolean {
        if (safetyCheck())
            return extensionContext.call("canGoForward");
        return false;
    }

    public function backForwardList():BackForwardList {
        if (safetyCheck())
            return extensionContext.call("backForwardList") as BackForwardList;
        return new BackForwardList();
    }

    public function removeFromStage():void {
        if (safetyCheck())
            extensionContext.call("removeFromStage");
    }

    public function load(url:String):void {
        if (safetyCheck())
            extensionContext.call("load", url);
    }

    public function loadHTMLString(html:String):void {
        if (safetyCheck())
            extensionContext.call("loadHTMLString", html);
    }

    public function loadFileURL(url:String, allowingReadAccessTo:String):void {
        if (safetyCheck())
            extensionContext.call("loadFileURL", url, allowingReadAccessTo);
    }

    public function evaluateJavaScript(javascript:String):void {
        if (safetyCheck())
            extensionContext.call("evaluateJavaScript", javascript);
    }

    public function reload():void {
        if (safetyCheck())
            extensionContext.call("reload");
    }

    public function stopLoading():void {
        if (safetyCheck())
            extensionContext.call("stopLoading");
    }

    public function goBack():void {
        if (safetyCheck())
            extensionContext.call("goBack");
    }

    public function goForward():void {
        if (safetyCheck())
            extensionContext.call("goForward");
    }

    public function go(offset:int = 1):void {
        if (safetyCheck())
            extensionContext.call("go",offset);
    }

    public function reloadFromOrigin():void {
        if (safetyCheck())
            extensionContext.call("reloadFromOrigin");
    }

    public function allowsMagnification():Boolean {
        if (safetyCheck())
            extensionContext.call("allowsMagnification");
        return false;
    }

    public function getMagnification():Number {
        if (safetyCheck())
            return extensionContext.call("getMagnification") as Number;
        return 1.0;
    }

    public function setMagnification(value:Number, centeredAt:Point):void {
        if (safetyCheck())
            extensionContext.call("setMagnification", value, centeredAt);
    }

    private function safetyCheck():Boolean {
        if (!isInited) {
            trace("You need to init first")
            return false;
        }
        return _isSupported;
    }

    public function isSupported():Boolean {
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