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

import flash.display.BitmapData;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.geom.Point;
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
        // trace("gotEvent",event);
        var keyName:String;
        var argsAsJSON:Object;
        var pObj:Object;
        switch (event.level) {
            case "TRACE":
                trace(event.code);
                break;

            case WebViewEvent.ON_PROPERTY_CHANGE:
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
                } else if (pObj.propName == "statusMessage") {
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
                    downloadProgress.url = pObj.url;
                    dispatchEvent(new WebViewEvent(WebViewEvent.ON_DOWNLOAD_PROGRESS, downloadProgress));
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }

                break;
            case WebViewEvent.ON_DOWNLOAD_COMPLETE:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_DOWNLOAD_COMPLETE, event.code));
                break;
            case WebViewEvent.ON_DOWNLOAD_CANCEL:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_DOWNLOAD_CANCEL, event.code));
                break;
            case WebViewEvent.ON_ESC_KEY:
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_ESC_KEY, event.code));
                break;
            case WebViewEvent.ON_PERMISSION_RESULT:
                try {
                    pObj = JSON.parse(event.code);
                    var permission:Object = new Object();
                    permission.result = pObj.result;
                    permission.type = pObj.type;
                    dispatchEvent(new WebViewEvent(WebViewEvent.ON_PERMISSION_RESULT, permission));
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }


            default:
                break;
        }
    }

    /**
     *
     * @param functionName name of the function as called from Javascript
     * @param closure Actionscript function to call when functionName is called from Javascript
     *
     * <p>Adds a callback in the webView. These should be added before .init() is called.</p>
     *
     */
    public function addCallback(functionName:String, closure:Function):void {
        jsCallBacks[functionName] = closure;
    }

    /**
     *
     * @param functionName name of the function to remove. This function should have been added via .addCallback() method
     *
     */
    public function removeCallback(functionName:String):void {
        jsCallBacks[functionName] = null;
    }


    /**
     *
     * @param functionName name of the Javascript function to call
     * @param closure Actionscript function to call when Javascript functionName is called. If null then no
     * actionscript function is called, aka a 'fire and forget' call.
     * @param args arguments to send to the Javascript function
     *
     * <p>Call a javascript function.</p>
     *
     * @example
     <listing version="3.0">
     // Logs to the console. No result expected.
     webView.callJavascriptFunction("as_to_js",asToJsCallback,1,"a",77);

     public function asToJsCallback(jsResult:JavascriptResult):void {
    trace("asToJsCallback");
    trace("jsResult.error", jsResult.error);
    trace("jsResult.result", jsResult.result);
    trace("jsResult.message", jsResult.message);
    trace("jsResult.success", jsResult.success);
    var testObject:* = jsResult.result;
    trace(testObject);
}
     }
     </listing>

     * @example
     <listing version="3.0">
     // Calls Javascript function passing 3 args. Javascript function returns an object which is automatically mapped to an
     Actionscript Object
     webView.callJavascriptFunction("console.log",null,"hello console. The is AIR");
     }

     // function in HTML page
     function as_to_js(numberA, stringA, numberB, obj) {
    var person = {
        name: "Jim Cowart",
        response: {
            name: "Chattanooga",
            population: 167674
        }
    };
    return person;
}
     </listing>
     */
    public function callJavascriptFunction(functionName:String, closure:Function = null, ...args):void {
        if (safetyCheck()) {
            var finalArray:Array = [];
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
     * @param js Javascript string to evaluate.
     * @param closure Actionscript function to call when the Javascript string is evaluated. If null then no
     * actionscript function is called, aka a 'fire and forget' call.
     *
     * @example
     <listing version="3.0">
     // Set the body background to yellow. No result expected
     webView.evaluateJavascript('document.getElementsByTagName("body")[0].style.backgroundColor = "yellow";');
     </listing>
     * @example
     <listing version="3.0">
     // Retrieve contents of div. Result is returned to Actionscript function 'onJsEvaluated'
     webView.evaluateJavascript("document.getElementById('output').innerHTML;", onJsEvaluated)
     private function onJsEvaluated(jsResult:JavascriptResult):void {
    trace("innerHTML of div is:", jsResult.result);
}
     </listing>
     *
     */
    public function evaluateJavascript(code:String, closure:Function = null):void {
        if (safetyCheck()) {
            if (closure != null) {
                var guid:String = GUID.create();
                asCallBacks[AS_CALLBACK_PREFIX + guid] = closure;
                extensionContext.call("evaluateJavaScript", code, AS_CALLBACK_PREFIX + guid);
            } else {
                extensionContext.call("evaluateJavaScript", code, null);
            }
        }
    }

    /**
     *
     * @param initialUrl Url to load when the view loads
     * @param x
     * @param y
     * @param width
     * @param height
     * @param settings
     * @param scaleFactor iOS and Android only
     *
     * <p>Initialises the webView. The webView is not automatically added to the native stage.</p>
     *
     */
    public function init(initialUrl:String = null, x:int = 0, y:int = 0, width:int = 800, height:int = 600,
                         settings:Settings = null, scaleFactor:int = 1):void {
        this._x = x;
        this._y = y;
        this._width = width;
        this._height = height;

        if (_isSupported) {
            var _settings:Settings = settings;
            if (_settings == null) {
                _settings = new Settings();
            }
            extensionContext.call("init", initialUrl, this._x, this._y, this._width, this._height, _settings, scaleFactor);
            _isInited = true;
        }
    }

    /**
     *
     * @param x
     * @param y
     * @param width set to 0 to retain existing
     * @param height  set to 0 to retain existing
     *
     * <p>Resizes and/or repositions the webView.</p>
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
     * <p>Adds the webView from the native stage.</p>
     *
     */
    public function addToStage():void {
        if (safetyCheck())
            extensionContext.call("addToStage");
    }

    /**
     * <p>Removes the webView from the native stage.</p>
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
     * @param html HTML provided as a string
     * @param baseUrl url which will display as the address
     *
     * <p>Loads a HTML string into the webView.</p>
     *
     */
    public function loadHTMLString(html:String, baseUrl:String = ""):void {
        if (safetyCheck())
            extensionContext.call("loadHTMLString", html, baseUrl);
    }

    /**
     *
     * @param url full path to the file on the local file system
     * @param allowingReadAccessTo path to the root of the document
     *
     * <p>Loads a file from the local file system into the webView.</p>
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
     * <p><strong>Ignored on Windows and Android.</strong></p>
     */
    public function backForwardList():BackForwardList {
        if (safetyCheck())
            return extensionContext.call("backForwardList") as BackForwardList;
        return new BackForwardList();
    }

    /**
     * Forces a reload of the page (i.e. ctrl F5)
     *
     */
    public function reloadFromOrigin():void {
        if (safetyCheck())
            extensionContext.call("reloadFromOrigin");
    }

    /**
     *
     * @param fs When going fullscreen set this to true, when coming out of fullscreen set to false
     *
     */
    public function onFullScreen(fs:Boolean = false):void {
        if (safetyCheck())
            extensionContext.call("onFullScreen", fs);
    }

    /**
     *
     * @return Whether the page allows magnification functionality
     * <p><strong>Ignored on iOS and Android.</strong></p>
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
     * <p><strong>Ignored on iOS and Android.</strong></p>
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
            trace("You need to init first");
            return false;
        }
        return _isSupported;
    }

    /**
     *
     * @return true if the device is Windows 7+, OSX 10.10+ or iOS 9.0+
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
     * <p>A Boolean value indicating whether we can navigate back.</p>
     *
     */
    public function get canGoBack():Boolean {
        return _canGoBack;
    }

    /**
     *
     * @return whether we can navigate forward
     *
     * <p>A Boolean value indicating whether we can navigate forward.</p>
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
     * <p>Shows the Chromium dev tools on Windows</p>
     * <p>On Android use Chrome on connected computer and navigate to chrome://inspect</p>
     *
     */
    public function showDevTools():void {
        if (safetyCheck())
            extensionContext.call("showDevTools");
    }

    /**
     * <p>Close the Chromium dev tools</p>
     * <p>On Android disconnects from chrome://inspect</p>
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
     * @param alpha set to 0.0 for transparent background. iOS and Android only.
     *
     * <p><strong>Ignored on OSX.</strong></p>
     */
    public function setBackgroundColor(value:uint, alpha:Number = 1.0):void {
        backgroundColor.hexToRGB(value);
        if (extensionContext)
            extensionContext.call("setBackgroundColor", backgroundColor.red, backgroundColor.green, backgroundColor.blue, alpha);
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
        if (safetyCheck())
            extensionContext.call("shutDown");
    }

    public function focus():void {
        if (safetyCheck())
            extensionContext.call("focus");
    }

    /**
     *
     * @param code Javascript to inject, if any.
     * @param scriptUrl is the URL where the script in question can be found, if any. Windows only
     * @param startLine is the base line number to use for error reporting. Windows only
     *
     * <p>Specify either code or scriptUrl. These are injected into the main Frame when it is loaded. Call before
     * load() method</p>
     * <p><strong>Ignored on Android.</strong></p>
     */

    public function injectScript(code:String = null, scriptUrl:String = null, startLine:uint = 0):void {
        if (code != null || scriptUrl != null) {
            extensionContext.call("injectScript", code, scriptUrl, startLine);
        }
    }


    /**
     *
     * <p>prints the webView.</p>
     * <p><strong>Windows only.</strong></p>
     *
     */
    public function print():void {
        extensionContext.call("print");
    }

    /**
     *
     * @param x
     * @param y
     * @param width leaving as default of 0 captures the full width
     * @param height leaving as default of 0 captures the full height
     *
     * <p>Captures the webView to BitmapData.</p>
     * <p><strong>Windows only.</strong></p>
     *
     */
    public function capture(x:int = 0, y:int = 0, width:int = 0, height:int = 0):BitmapData {
        return extensionContext.call("capture", x, y, width, height) as BitmapData;
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