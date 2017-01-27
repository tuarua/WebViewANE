/*
 * Copyright Tua Rua Ltd. (c) 2017.
 */
package com.tuarua {
import com.tuarua.utils.GUID;
import com.tuarua.webview.ActionscriptCallback;
import com.tuarua.webview.BackForwardList;
import com.tuarua.webview.DownloadProgress;
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
    private var _isInited:Boolean = false;
    private var _isSupported:Boolean = false;

    private var _url:String;
    private var _title:String;
    private var _isLoading:Boolean;
    private var _canGoBack:Boolean;
    private var _canGoForward:Boolean;
    private var _estimatedProgress:Number;
    private var _statusMessage:String;
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
    private var backgroundColor:RGB = new RGB(0xFFFFFF);
    private var downloadProgress:DownloadProgress = new DownloadProgress();
    public function WebViewANE() {
        initiate();
    }
	/** 
	 * This method is omitted from the output. * * @private 
	 */ 
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
	/** 
	 * This method is omitted from the output. * * @private 
	 */ 
    private function gotEvent(event:StatusEvent):void {
        // trace(event);
        var keyName:String;
        var argsAsJSON:Object;
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
                }else if(pObj.propName == "statusMessage"){
                    _statusMessage = pObj.value;
                }

                dispatchEvent(new WebViewEvent(WebViewEvent.ON_PROPERTY_CHANGE, pObj.propName));
                break;
            case WebViewEvent.ON_FAIL:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_FAIL, (event.code.length > 0)
                        ? JSON.parse(event.code) : null));
                break;

            case JS_CALLBACK_EVENT: //js->as->js
                try {
                    argsAsJSON = JSON.parse(event.code);
                    for (var key:Object in jsCallBacks) {
                        var asCallback:ActionscriptCallback = new ActionscriptCallback();
                        keyName = key as String;
                        if (keyName == argsAsJSON.functionName) {
                            var tmpFunction1:Function = jsCallBacks[key] as Function;
                            asCallback.functionName = argsAsJSON.functionName;
                            asCallback.callbackName = argsAsJSON.callbackName;
                            asCallback.args = argsAsJSON.args;
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
                    argsAsJSON = JSON.parse(event.code);
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                for (var keyAs:Object in asCallBacks) {
                    keyName = keyAs as String;

                    if (keyName == argsAsJSON.callbackName) {
                        var jsResult:JavascriptResult = new JavascriptResult();
                        jsResult.error = argsAsJSON.error;
                        jsResult.message = argsAsJSON.message;
                        jsResult.success = argsAsJSON.success;
                        jsResult.result = argsAsJSON.result;

                        var tmpFunction2:Function = asCallBacks[keyAs] as Function;
                        tmpFunction2.call(null, jsResult);
                    }
                }
                break;
            case WebViewEvent.ON_DOWNLOAD_PROGRESS:
                try {
                    pObj = JSON.parse(event.code);
                    downloadProgress.bytesLoaded = pObj.bytesLoaded;
                    downloadProgress.bytesTotal = pObj.bytesTotal;
                    downloadProgress.percent = pObj.percent;
                    downloadProgress.speed = pObj.speed;
                    downloadProgress.id = pObj.id;
                    dispatchEvent(new WebViewEvent(WebViewEvent.ON_DOWNLOAD_PROGRESS, downloadProgress));
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }

                break;
            case WebViewEvent.ON_DOWNLOAD_COMPLETE:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_DOWNLOAD_PROGRESS, event.code));
                break;
            case WebViewEvent.ON_DOWNLOAD_CANCEL:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_DOWNLOAD_CANCEL, event.code));
                break;
            default:
                break;
        }
    }
	/**
	 * 
	 * @param functionName
	 * @param closure
	 * 
	 */
    public function addCallback(functionName:String, closure:Function):void {
        jsCallBacks[functionName] = closure;
    }
	/**
	 * 
	 * @param functionName
	 * 
	 */
    public function removeCallback(functionName:String):void {
        jsCallBacks[functionName] = null;
    }

    //to call js method with args, no closure=fire and forget
	/**
	 * 
	 * @param functionName
	 * @param closure
	 * @param args
	 * 
	 */	
    public function callJavascriptFunction(functionName:String, closure:Function = null, ...args):void {
        if (safetyCheck()) {
            var finalArray:Array = new Array();
            for each (var arg:* in args)
                finalArray.push(JSON.stringify(arg));
            var js:String = functionName + "(" + finalArray.toString() + ");";
            if (closure != null) {
                asCallBacks[AS_CALLBACK_PREFIX + functionName] = closure;
                extensionContext.call("callJavascriptFunction", js, AS_CALLBACK_PREFIX + functionName);
            } else {
                extensionContext.call("callJavascriptFunction", js, null);
            }
        }
    }

    //to insert script or run some js, no closure fire and forget
	/**
	 * 
	 * @param js
	 * @param closure
	 * 
	 */	
    public function evaluateJavascript(js:String, closure:Function = null):void {
        if (safetyCheck()) {
            if (closure != null) {
                var guid:String = GUID.create();
                asCallBacks[AS_CALLBACK_PREFIX + guid] = closure;
                extensionContext.call("evaluateJavaScript", js, AS_CALLBACK_PREFIX + guid);
            } else {
                extensionContext.call("evaluateJavaScript", js, null);
            }
        }
    }
	/**
	 * 
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 * @param settings
	 * 
	 */
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
            _isInited = true;
        }
    }
	/**
	 * 
	 * @param x
	 * @param y
	 * @param width
	 * @param height
	 * 
	 */
    public function setPositionAndSize(x:int = 0, y:int = 0, width:int = 0, height:int = 0):void {
        this._x = x;
        this._y = y;
        if (width > 0) this._width = width;
        if (height > 0) this._height = height;

        if (safetyCheck()) {
            extensionContext.call("setPositionAndSize", this._x, this._y, this._width, this._height);
        }
    }
	/**
	 * 
	 * 
	 */
    public function addToStage():void {
        if (safetyCheck())
            extensionContext.call("addToStage");
    }
	/**
	 * 
	 * 
	 */
    public function removeFromStage():void {
        if (safetyCheck())
            extensionContext.call("removeFromStage");
    }
	/**
	 * 
	 * @param url
	 * 
	 */
    public function load(url:String):void {
        if (safetyCheck())
            extensionContext.call("load", url);
    }
	/**
	 * 
	 * @param html
	 * @param baseUrl
	 * 
	 */
    public function loadHTMLString(html:String, baseUrl:String = ""):void {
        if (safetyCheck())
            extensionContext.call("loadHTMLString", html, baseUrl);
    }
	/**
	 * 
	 * @param url
	 * @param allowingReadAccessTo
	 * 
	 */
    public function loadFileURL(url:String, allowingReadAccessTo:String):void {
        if (safetyCheck())
            extensionContext.call("loadFileURL", url, allowingReadAccessTo);
    }
	/** 
	 * <p>Reloads the current page.</p>
	 */
    public function reload():void {
        if (safetyCheck())
            extensionContext.call("reload");
    }
	/** 
	 * <p>Stops loading the current page.</p>
	 */
    public function stopLoading():void {
        if (safetyCheck())
            extensionContext.call("stopLoading");
    }
	/** 
	 * <p>Navigates back.</p>
	 */
    public function goBack():void {
        if (safetyCheck())
            extensionContext.call("goBack");
    }
	/**
	 * <p>Navigates forward.</p>
	 */
    public function goForward():void {
        if (safetyCheck())
            extensionContext.call("goForward");
    }
	/**
	 * 
	 * @param offset Navigate forward (eg +1) or back (eg -1)
	 * 
	 */
    public function go(offset:int = 1):void {
        if (safetyCheck())
            extensionContext.call("go", offset);
    }
	/**
	 * 
	 * @return 
	 * 
	 */
    public function backForwardList():BackForwardList {
        if (safetyCheck())
            return extensionContext.call("backForwardList") as BackForwardList;
        return new BackForwardList();
    }
	/**
	 * 
	 * 
	 */
    public function reloadFromOrigin():void {
        if (safetyCheck())
            extensionContext.call("reloadFromOrigin");
    }
	/**
	 * 
	 * @param fs
	 * 
	 */
    public function onFullScreen(fs:Boolean = false):void {
        if (safetyCheck())
            extensionContext.call("onFullScreen", fs);
    }
	/**
	 * 
	 * @return Whether the page allows magnification functionality
	 * 
	 */
    public function allowsMagnification():Boolean {
        if (safetyCheck())
            extensionContext.call("allowsMagnification");
        return false;
    }
	/**
	 * 
	 * @return The current magnification level
	 * 
	 */
    public function getMagnification():Number {
        if (safetyCheck())
            return extensionContext.call("getMagnification") as Number;
        return 1.0;
    }
	
	/**
	 * 
	 * @param value
	 * @param centeredAt
	 * 
	 */
    public function setMagnification(value:Number, centeredAt:Point):void {
        if (safetyCheck())
            extensionContext.call("setMagnification", value, centeredAt);
    }
	/** 
	 * This method is omitted from the output. * * @private 
	 */ 
    private function safetyCheck():Boolean {
        if (!_isInited) {
            trace("You need to init first")
            return false;
        }
        return _isSupported;
    }
	/**
	 * 
	 * @return true if the device is Windows 7+ or OSX 10.10+
	 * 
	 */
    public function isSupported():Boolean {
        return _isSupported;
    }
	/**
	 * 
	 * 
	 */
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
	/**
	 * 
	 * @return current url
	 * 
	 */
    public function get url():String {
        return _url;
    }
	/**
	 * 
	 * @return current page title
	 * 
	 */
    public function get title():String {
        return _title;
    }
	/**
	 * 
	 * @return whether the page is loading
	 * 
	 */
    public function get isLoading():Boolean {
        return _isLoading;
    }
	/**
	 * 
	 * @return whether we can navigate back
	 * 
	 */
    public function get canGoBack():Boolean {
        return _canGoBack;
    }
	/**
	 * 
	 * @return whether we can navigate forward
	 * 
	 */
    public function get canGoForward():Boolean {
        return _canGoForward;
    }
	/**
	 * 
	 * @return estimated progress between 0.0 and 1.0. 
	 * Available on OSX only
	 * 
	 */
    public function get estimatedProgress():Number {
        return _estimatedProgress;
    }
	/**
	 * <p>Shows the Chromium dev tools</p>
	 * <p><strong>Windows only.</strong></p>
	 * 
	 */
    public function showDevTools():void {
        if (safetyCheck())
            extensionContext.call("showDevTools");
    }
	/**
	 * <p>Close the Chromium dev tools</p>
	 * <p><strong>Windows only.</strong></p>
	 * 
	 */
    public function closeDevTools():void {
        if (safetyCheck())
            extensionContext.call("closeDevTools");
    }
	/**
	 * 
	 * @param value hex value of the view's background color.
	 * <p>This should be set as the default is #000000 (black).</p>
	 * <p><strong>Applicable to Windows only.</strong></p>
	 * 
	 */
    public function setBackgroundColor(value:uint):void {
        backgroundColor.hexToRGB(value);
        extensionContext.call("setBackgroundColor",backgroundColor.red,backgroundColor.green,backgroundColor.blue);
    }
	/**
	 * 
	 * @return whether we have inited the webview
	 * 
	 */
    public function get isInited():Boolean {
        return _isInited;
    }
	/**
	 * 
	 * @return current status message (This would normally appear on the bottom left of a browser)
	 * <p><strong>Windows only.</strong></p>
	 * 
	 */
    public function get statusMessage():String {
        return _statusMessage;
    }
    /**
     * <p>This calls Cef.ShutDown() to clean up all Chromium Embedded Framework processes.</p>
     * <p><strong>Applicable to Windows only.</strong></p>
     * @example
     * <listing version="3.0">
     NativeApplication.nativeApplication.addEventListener(flash.events.Event.EXITING, onExiting);
     private function onExiting(event:Event):void {
        webView.shutDown();
     }</listing>
     *
     */
	public function shutDown():void {
        extensionContext.call("shutDown");
    }
	
}
}

internal class RGB {
    public var red:int = 255;
    public var green:int = 255;
    public var blue:int = 255;

    public function RGB(hex:uint) {
        hexToRGB(hex);
    }
    public function hexToRGB(hex:uint):void {
        red = ((hex & 0xFF0000) >> 16);
        green = ((hex & 0x00FF00) >> 8);
        blue = ((hex & 0x0000FF));
    }
}