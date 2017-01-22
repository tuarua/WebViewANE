/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */
package com.tuarua {
import com.tuarua.utils.GUID;
import com.tuarua.webview.ActionscriptCallback;
import com.tuarua.webview.BackForwardList;
import com.tuarua.webview.JavascriptResult;
import com.tuarua.webview.Settings;
import com.tuarua.webview.WebViewEvent;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.utils.Dictionary;

public class WebViewANE extends EventDispatcher {
    private static const name:String = "WebViewANE";
    private var extensionContext:ExtensionContext;
    private var isInited:Boolean = false;
    private var _isSupported:Boolean = false;

    private var _url:String;
    private var _title:String;
    private var _isLoading:Boolean;
    private var _canGoBack:Boolean;
    private var _canGoForward:Boolean;
    private var _estimatedProgress:Number;
    private var _x:int;
    private var _y:int;
    private var _height:int;
    private var _width:int;
    private var asCallBacks:Dictionary = new Dictionary(); // as -> js -> as
    private var jsCallBacks:Dictionary = new Dictionary(); //js - > as -> js
    private static const AS_CALLBACK_PREFIX:String = "TRWV.as.";
    private static const JS_CALLBACK_PREFIX:String = "TRWV.js.";

    private static const JS_CALLBACK_EVENT:String = "TRWV.js.CALLBACK";
    private static const AS_CALLBACK_EVENT:String = "TRWV.as.CALLBACK";

    public function WebViewANE() {
        initiate();
    }

    protected function initiate():void {
        _isSupported = true;

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
        // trace(event);
        var keyName:String;
        var paramsAsJSON:Object;
        var pObj:Object;
        switch (event.level) {
            case "TRACE":
                trace(event.code);
                break;

            case WebViewEvent.ON_PROPERTY_CHANGE:
                //trace(event.code);
                pObj = JSON.parse(event.code);
                if (pObj.propName == "url") {
                    _url = pObj.value;
                } else if (pObj.propName == "title") {
                    _title = pObj.value;
                } else if (pObj.propName == "isLoading") {
                    _isLoading = pObj.value;
                } else if (pObj.propName == "canGoBack") {
                    _canGoBack = pObj.value;
                } else if (pObj.propName == "canGoForward") {
                    _canGoForward = pObj.value;
                } else if (pObj.propName == "estimatedProgress") {
                    _estimatedProgress = pObj.value;
                }

                dispatchEvent(new WebViewEvent(WebViewEvent.ON_PROPERTY_CHANGE, pObj.propName));
                break;
            case WebViewEvent.ON_FAIL:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_FAIL, (event.code.length > 0)
                        ? JSON.parse(event.code) : null));
                break;

            case JS_CALLBACK_EVENT: //js->as->js
                try {
                    paramsAsJSON = JSON.parse(event.code);
                    for (var key:Object in jsCallBacks) {
                        var asCallback:ActionscriptCallback = new ActionscriptCallback();
                        keyName = key as String;
                        if (keyName == paramsAsJSON.functionName) {
                            var tmpFunction1:Function = jsCallBacks[key] as Function;
                            asCallback.functionName = paramsAsJSON.functionName;
                            asCallback.callbackName = paramsAsJSON.callbackName;
                            asCallback.args = paramsAsJSON.args;
                            tmpFunction1.call(null, asCallback);
                            break;
                        }
                    }

                } catch (e:Error) {
                    trace(e.message);
                    break;
                }

                break;
            case AS_CALLBACK_EVENT:

                try {
                    paramsAsJSON = JSON.parse(event.code);
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                for (var keyAs:Object in asCallBacks) {
                    keyName = keyAs as String;

                    if (keyName == paramsAsJSON.callbackName) {
                        var jsResult:JavascriptResult = new JavascriptResult();
                        jsResult.error = paramsAsJSON.error;
                        jsResult.message = paramsAsJSON.message;
                        jsResult.success = paramsAsJSON.success;
                        jsResult.result = paramsAsJSON.result;

                        var tmpFunction2:Function = asCallBacks[keyAs] as Function;
                        tmpFunction2.call(null, jsResult);
                    }
                }
                break;
            default:
                break;
        }
    }

    public function addCallback(functionName:String, closure:Function):void {
        jsCallBacks[functionName] = closure;
    }

    public function removeCallback(functionName:String):void {
        jsCallBacks[functionName] = null;
    }

    //to call js method with args, no closure=fire and forget
    public function callJavascriptFunction(functionName:String, closure:Function = null, ...args):void {
        if (safetyCheck()) {
            var finalArray:Array = new Array();
            for each (var arg:* in args)
                finalArray.push(JSON.stringify(arg));
            var js:String = functionName + "(" + finalArray.toString() + ");";
            if (closure) {
                asCallBacks[AS_CALLBACK_PREFIX + functionName] = closure;
                extensionContext.call("callJavascriptFunction", js, AS_CALLBACK_PREFIX + functionName);
            } else {
                extensionContext.call("callJavascriptFunction", js, null);
            }
        }
    }

    //to insert script or run some js, no closure fire and forget
    public function evaluateJavascript(js:String, closure:Function = null):void {
        if (safetyCheck()) {
            if (closure) {
                var guid:String = GUID.create();
                asCallBacks[AS_CALLBACK_PREFIX + guid] = closure;
                extensionContext.call("evaluateJavaScript", js, AS_CALLBACK_PREFIX + guid);
            } else {
                extensionContext.call("evaluateJavaScript", js, null);
            }
        }
    }

    public function init(x:int = 0, y:int = 0, width:int = 800, height:int = 600, settings:Settings = null):void {
        this._x = x;
        this._y = y;
        this._width = width;
        this._height = height;

        if (_isSupported) {
            var _settings:Settings = settings;
            if (_settings == null) {
                _settings = new Settings();
            }
            extensionContext.call("init", this._x, this._y, this._width, this._height, _settings);
            isInited = true;
        }
    }

    public function setPositionAndSize(x:int = 0, y:int = 0, width:int = 0, height:int = 0):void {
        this._x = x;
        this._y = y;
        if (width > 0) this._width = width;
        if (height > 0) this._height = height;

        if (safetyCheck()) {
            extensionContext.call("setPositionAndSize", this._x, this._y, this._width, this._height);
        }
    }

    public function addToStage():void {
        if (safetyCheck())
            extensionContext.call("addToStage");
    }

    public function removeFromStage():void {
        if (safetyCheck())
            extensionContext.call("removeFromStage");
    }

    public function load(url:String):void {
        if (safetyCheck())
            extensionContext.call("load", url);
    }

    public function loadHTMLString(html:String, baseUrl:String = ""):void {
        if (safetyCheck())
            extensionContext.call("loadHTMLString", html, baseUrl);
    }

    public function loadFileURL(url:String, allowingReadAccessTo:String):void {
        if (safetyCheck())
            extensionContext.call("loadFileURL", url, allowingReadAccessTo);
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
            extensionContext.call("go", offset);
    }

    public function backForwardList():BackForwardList {
        if (safetyCheck())
            return extensionContext.call("backForwardList") as BackForwardList;
        return new BackForwardList();
    }

    public function reloadFromOrigin():void {
        if (safetyCheck())
            extensionContext.call("reloadFromOrigin");
    }

    public function onFullScreen(fs:Boolean = false):void {
        if (safetyCheck())
            extensionContext.call("onFullScreen", fs);
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

    public function get url():String {
        return _url;
    }

    public function get title():String {
        return _title;
    }

    public function get isLoading():Boolean {
        return _isLoading;
    }

    public function get canGoBack():Boolean {
        return _canGoBack;
    }

    public function get canGoForward():Boolean {
        return _canGoForward;
    }

    public function get estimatedProgress():Number {
        return _estimatedProgress;
    }

    public function showDevTools():void {
        if (safetyCheck())
            extensionContext.call("showDevTools");
    }

    public function closeDevTools():void {
        if (safetyCheck())
            extensionContext.call("closeDevTools");
    }


}
}