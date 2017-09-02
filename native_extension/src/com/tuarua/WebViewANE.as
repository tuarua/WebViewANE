/*
 * Copyright 2017 Tua Rua Ltd.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *  Additional Terms
 *  No part, or derivative of this Air Native Extensions's code is permitted
 *  to be sold as the basis of a commercially packaged Air Native Extension which
 *  undertakes the same purpose as this software. That is, a WebView for Windows,
 *  OSX and/or iOS and/or Android.
 *  All Rights Reserved. Tua Rua Ltd.
 */

package com.tuarua {
import com.tuarua.fre.ANEError;
import com.tuarua.utils.GUID;
import com.tuarua.utils.os;
import com.tuarua.webview.ActionscriptCallback;
import com.tuarua.webview.BackForwardList;
import com.tuarua.webview.DownloadProgress;
import com.tuarua.webview.JavascriptResult;
import com.tuarua.webview.Settings;
import com.tuarua.webview.TabDetails;
import com.tuarua.webview.WebViewEvent;

import flash.desktop.NativeApplication;

import flash.display.BitmapData;
import flash.display.NativeWindowDisplayState;
import flash.display.Stage;
import flash.display.StageDisplayState;

import flash.events.EventDispatcher;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.system.Capabilities;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

public class WebViewANE extends EventDispatcher {
    private static const name:String = "WebViewANE";
    private var _isInited:Boolean = false;
    private var _isSupported:Boolean = false;
    private var _viewPort:Rectangle;
    private var asCallBacks:Dictionary = new Dictionary(); // as -> js -> as
    private var jsCallBacks:Dictionary = new Dictionary(); //js - > as -> js
    private static const AS_CALLBACK_PREFIX:String = "TRWV.as.";
    private static const JS_CALLBACK_PREFIX:String = "TRWV.js.";
    private static const JS_CALLBACK_EVENT:String = "TRWV.js.CALLBACK";
    private static const AS_CALLBACK_EVENT:String = "TRWV.as.CALLBACK";
    private static const ON_ESC_KEY:String = "WebView.OnEscKey";
    private static const ON_KEY_UP:String = "WebView.OnKeyUp";
    private static const ON_KEY_DOWN:String = "WebView.OnKeyDown";
    private var downloadProgress:DownloadProgress = new DownloadProgress();
    private var _visible:Boolean;
    private var _backgroundColor:uint = 0xFFFFFF;
    private var _backgroundAlpha:Number = 1.0;
    private var _stage:Stage;
    private var _settings:Settings;
    private var ctx:ExtensionContext;

    public function WebViewANE() {
        initiate();
    }

    /**
     * This method is omitted from the output. * * @private
     */
    private function initiate():void {
        _isSupported = true;

        if (_isSupported) {
            trace("[" + name + "] Initalizing ANE...");
            try {
                ctx = ExtensionContext.createExtensionContext("com.tuarua." + name, null);
                ctx.addEventListener(StatusEvent.STATUS, gotEvent);
                _isSupported = ctx.call("isSupported");
            } catch (e:Error) {
                trace(e.name);
                trace(e.message);
                trace(e.getStackTrace());
                trace(e.errorID);
                trace("[" + name + "] ANE Not loaded properly.  Future calls will fail.");
            }
        } else {
            trace("[" + name + "] Can't initialize.");
        }

    }

    /**
     * This method is omitted from the output. * * @private
     */
    private function gotEvent(event:StatusEvent):void {
        //trace("gotEvent", event);
        var keyName:String;
        var argsAsJSON:Object;
        var pObj:Object;
        switch (event.level) {
            case "TRACE":
                trace(event.code);
                break;
            case ON_KEY_DOWN:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var systemKeyDown:Boolean = argsAsJSON.isSystemKey;
                    var modifiersDown:String = (argsAsJSON.modifiers as String).toLowerCase();
                    var shiftDown:Boolean = modifiersDown.indexOf("shift") > -1;
                    var controlDown:Boolean = modifiersDown.indexOf("control") > -1;
                    var commandDown:Boolean = modifiersDown.indexOf("command") > -1;
                    var altDown:Boolean = modifiersDown.indexOf("alt") > -1 && !systemKeyDown;
                    this.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 0, argsAsJSON.keyCode, 0,
                            controlDown, altDown, shiftDown, controlDown, commandDown));
                } catch (e:Error) {
                    trace(e.getStackTrace());
                    break;
                }
                break;
            case ON_KEY_UP:
                try {
                    argsAsJSON = JSON.parse(event.code);
                    var systemKeyUp:Boolean = argsAsJSON.isSystemKey;
                    var modifiersUp:String = (argsAsJSON.modifiers as String).toLowerCase();
                    var shiftUp:Boolean = modifiersUp.indexOf("shift") > -1;
                    var controlUp:Boolean = modifiersUp.indexOf("control") > -1;
                    var commandUp:Boolean = modifiersUp.indexOf("command") > -1;
                    var altUp:Boolean = modifiersUp.indexOf("alt") > -1 && !systemKeyUp;
                    this.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, argsAsJSON.keyCode, 0,
                            controlUp, altUp, shiftUp, controlUp, commandUp));
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                break;
            case ON_ESC_KEY:
                _stage.displayState = StageDisplayState.NORMAL;
                break;
            case WebViewEvent.ON_PROPERTY_CHANGE:
                pObj = JSON.parse(event.code);
                var tab:int = 0;
                if (pObj.hasOwnProperty("tab")) {
                    tab = pObj.tab;
                }
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_PROPERTY_CHANGE, {
                    propertyName: pObj.propName,
                    value: pObj.value,
                    tab: tab
                }));
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

            case WebViewEvent.ON_URL_BLOCKED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_URL_BLOCKED, argsAsJSON));
                break;
            case WebViewEvent.ON_POPUP_BLOCKED:
                try {
                    argsAsJSON = JSON.parse(event.code);
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                dispatchEvent(new WebViewEvent(WebViewEvent.ON_POPUP_BLOCKED, argsAsJSON));
                break;
            case WebViewEvent.ON_PERMISSION_RESULT:
                try {
                    pObj = JSON.parse(event.code);
                    var permission:Object = {};
                    permission.result = pObj.result;
                    permission.type = pObj.type;
                    dispatchEvent(new WebViewEvent(WebViewEvent.ON_PERMISSION_RESULT, permission));
                } catch (e:Error) {
                    trace(e.message);
                    break;
                }
                break;

            default:
                break;
        }
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        if (_isInited && (KeyboardEvent.KEY_UP == type || KeyboardEvent.KEY_DOWN == type) && (os.isWindows || os.isOSX)) {
            if (this.hasEventListener(type)) {
                ctx.call("addEventListener", type);
            }
        }
    }

    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        if (_isInited && (KeyboardEvent.KEY_UP == type || KeyboardEvent.KEY_DOWN == type) && (os.isWindows || os.isOSX)) {
            if (this.hasEventListener(type)) {
                ctx.call("removeEventListener", type);
            }
        }
        super.removeEventListener(type, listener, useCapture);
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
        if (functionName && closure) {
            jsCallBacks[functionName] = closure;
        } else {
            throw new ArgumentError("functionName and/or closure cannot be null");
        }
    }

    /**
     *
     * @param functionName name of the function to remove. This function should have been added via .addCallback() method
     *
     */
    public function removeCallback(functionName:String):void {
        if (functionName) {
            jsCallBacks[functionName] = null;
        } else {
            throw new ArgumentError("functionName cannot be null");
        }
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
        if (functionName == null) {
            throw new ArgumentError("functionName cannot be null");
        }
        if (safetyCheck()) {
            var theRet:* = null;
            var finalArray:Array = [];
            for each (var arg:* in args)
                finalArray.push(JSON.stringify(arg));
            var js:String = functionName + "(" + finalArray.toString() + ");";
            if (closure) {
                asCallBacks[AS_CALLBACK_PREFIX + functionName] = closure;
                theRet = ctx.call("callJavascriptFunction", js, AS_CALLBACK_PREFIX + functionName);
            } else {
                theRet = ctx.call("callJavascriptFunction", js, null);
            }
        }
    }

    //to insert script or run some js, no closure fire and forget
    /**
     *
     * @param code Javascript string to evaluate.
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
        if (code == null) {
            throw new ArgumentError("code cannot be null");
        }
        if (safetyCheck()) {
            var theRet:* = null;
            if (closure) {
                var guid:String = GUID.create();
                asCallBacks[AS_CALLBACK_PREFIX + guid] = closure;
                theRet = ctx.call("evaluateJavaScript", code, AS_CALLBACK_PREFIX + guid);
            } else {
                theRet = ctx.call("evaluateJavaScript", code, null);
            }
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    /**
     *
     * @param stage
     * @param viewPort
     * @param initialUrl Url to load when the view loads
     * @param settings
     * @param scaleFactor iOS and Android only
     * @param backgroundColor value of the view's background color.
     * @param backgroundAlpha set to 0.0 for transparent background. iOS and Android only
     *
     * <p>Initialises the webView. N.B. The webView is set to visible = false initially.</p>
     *
     */
    public function init(stage:Stage, viewPort:Rectangle, initialUrl:String = null,
                         settings:Settings = null, scaleFactor:Number = 1.0,
                         backgroundColor:uint = 0xFFFFFF, backgroundAlpha:Number = 1.0):void {
        if (viewPort == null) {
            throw new ArgumentError("viewPort cannot be null");
        }
        _stage = stage;
        _viewPort = viewPort;

        if (os.isOSX) {
            NativeApplication.nativeApplication.activeWindow.addEventListener(
                    NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowMiniMaxi, false, 1000);
        }
        stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent, false, 1000);

        //hasn't been set by setBackgroundColor
        if (_backgroundColor == 0xFFFFFF) {
            _backgroundColor = backgroundColor;
        }
        if (_backgroundAlpha == 1.0) {
            _backgroundAlpha = backgroundAlpha;
        }

        if (_isSupported) {
            _settings = settings;
            if (_settings == null) {
                _settings = new Settings();
            }

            var theRet:* = ctx.call("init", initialUrl, _viewPort, _settings, scaleFactor, _backgroundColor,
                    _backgroundAlpha);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }

            if ((os.isWindows || os.isOSX)) {
                if (this.hasEventListener(KeyboardEvent.KEY_UP)) {
                    trace("adding before init", KeyboardEvent.KEY_UP);
                    ctx.call("addEventListener", KeyboardEvent.KEY_UP);
                }
                if (this.hasEventListener(KeyboardEvent.KEY_DOWN)) {
                    trace("adding before init", KeyboardEvent.KEY_DOWN);
                    ctx.call("addEventListener", KeyboardEvent.KEY_DOWN);
                }
            }

            _isInited = true;
        }
    }

    private function onWindowMiniMaxi(event:NativeWindowDisplayStateEvent):void {
        /*
         !! Needed for OSX, restores webView when we restore from minimized state
         */
        if (event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED) {
            visible = false;
            visible = true;
            return;
        }

    }

    private function onFullScreenEvent(event:FullScreenEvent):void {
        if (safetyCheck()) {
            ctx.call("onFullScreen", event.fullScreen);
        }
    }

    /**
     *
     * @param url
     *
     */
    public function load(url:String):void {
        if (safetyCheck()) {
            var theRet:* = ctx.call("load", url);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
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
        if (safetyCheck()) {
            var theRet:* = ctx.call("loadHTMLString", html, baseUrl);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
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
        if (safetyCheck()) {
            var theRet:* = ctx.call("loadFileURL", url, allowingReadAccessTo);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    /**
     * <p>Reloads the current page.</p>
     */
    public function reload():void {
        if (safetyCheck()) {
            ctx.call("reload");
        }

    }

    /**
     * <p>Stops loading the current page.</p>
     */
    public function stopLoading():void {
        if (safetyCheck()) {
            ctx.call("stopLoading");
        }
    }

    /**
     * <p>Navigates back.</p>
     */
    public function goBack():void {
        if (safetyCheck()) {
            ctx.call("goBack");
        }
    }

    /**
     * <p>Navigates forward.</p>
     */
    public function goForward():void {
        if (safetyCheck()) {
            ctx.call("goForward");
        }
    }

    /**
     *
     * @param offset Navigate forward (eg +1) or back (eg -1)
     *
     */
    public function go(offset:int = 1):void {
        if (safetyCheck()) {
            ctx.call("go", offset);
        }

    }

    /**
     *
     * @return
     * <p><strong>Ignored on Windows and Android.</strong></p>
     */
    public function backForwardList():BackForwardList {
        if (safetyCheck()) {
            return ctx.call("backForwardList") as BackForwardList;
        }
        return new BackForwardList();
    }

    /**
     * Forces a reload of the page (i.e. ctrl F5)
     *
     */
    public function reloadFromOrigin():void {
        if (safetyCheck()) {
            ctx.call("reloadFromOrigin");
        }

    }

    /**
     * <p>Clears the browser cache. Available on iOS/OSX/Android only</p>
     * <p><strong>Ignored on Windows.</strong></p>
     * <p>You cannot clear the cache on Windows while CEF is running. This is a known limitation.
     * You can delete the contents of the value of your settings.cef.cachePath using Actionscript
     * only before you call .init(). Calling after .dispose() may cause file locks as the files may
     * still be 'owned' by the CEF process</p>
     *
     */
    public function clearCache():void {
        //Windows is special case.
        if (os.isWindows) {
            if (_isInited) {
                trace("[" + name + "] You cannot clear the cache on Windows while CEF is running. This is a known limitation. " +
                        "You can only call this method after .dispose() is called");
                return;
            }
            try {
                var cacheFolder:File = File.applicationDirectory.resolvePath(_settings.cef.cachePath);
                if (cacheFolder.exists) {
                    var files:Array = cacheFolder.getDirectoryListing();
                    for (var i:uint = 0; i < files.length; i++) {
                        var file:File = files[i];
                        if (file.isDirectory) {
                            file.deleteDirectory(true);
                        } else {
                            file.deleteFile();
                        }
                    }
                }
            } catch (e:Error) {
                trace("[" + name + "] unable to delete cache files");
            }
            return;
        }

        if (safetyCheck()) {
            ctx.call("clearCache");
        }
    }

    /**
     *
     * @return Whether the page allows magnification functionality
     * <p><strong>Ignored on iOS.</strong></p>
     */
    public function allowsMagnification():Boolean {
        if (safetyCheck()) {
            return ctx.call("allowsMagnification");
        }
        return false;
    }

    /**
     * Zooms in
     *
     */
    public function zoomIn():void {
        if (safetyCheck()) {
            ctx.call("zoomIn");
        }
    }

    /**
     * Zooms out
     *
     */
    public function zoomOut():void {
        if (safetyCheck()) {
            ctx.call("zoomOut");
        }
    }

    public function addTab(initialUrl:String = null):void {
        if (safetyCheck()) {
            var theRet:* = ctx.call("addTab", initialUrl);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    public function closeTab(index:int):void {
        if (safetyCheck()) {
            var theRet:* = ctx.call("closeTab", index);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    public function set currentTab(value:int):void {
        if (safetyCheck()) {
            var theRet:* = ctx.call("setCurrentTab", value);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    public function get currentTab():int {
        var ct:int = 0;
        if (safetyCheck()) {
            ct = int(ctx.call("getCurrentTab"));
        }
        return ct;
    }

    public function get tabDetails():Vector.<TabDetails> {
        var ret:Vector.<TabDetails> = new Vector.<TabDetails>();
        if (safetyCheck()) {
            var theRet:* = ctx.call("getTabDetails");
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
            ret = Vector.<TabDetails>(theRet);
        }
        return ret;

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
     * <p>This cleans up the webview and all related processes.</p>
     * <p><strong>It is important to call this when the app is exiting.</strong></p>
     * @example
     * <listing version="3.0">
     NativeApplication.nativeApplication.addEventListener(flash.events.Event.EXITING, onExiting);
     private function onExiting(event:Event):void {
        webView.dispose();
     }</listing>
     *
     */
    public function dispose():void {
        if (!ctx) {
            trace("[" + name + "] Error. ANE Already in a disposed or failed state...");
            return;
        }
        trace("[" + name + "] Unloading ANE...");
        ctx.removeEventListener(StatusEvent.STATUS, gotEvent);
        if (safetyCheck()) {
            ctx.call("shutDown");
        }
        ctx.dispose();
        ctx = null;
        _isInited = false;
    }

    /**
     * <p>Shows the Chromium dev tools on Windows</p>
     * <p>Enables Inspect Element on right click on OSX</p>
     * <p>On Android use Chrome on connected computer and navigate to chrome://inspect</p>
     *
     */
    public function showDevTools():void {
        if (safetyCheck())
            ctx.call("showDevTools");
    }

    /**
     * <p>Close the Chromium dev tools</p>
     * <p>Disables Inspect Element on right click on OSX</p>
     * <p>On Android disconnects from chrome://inspect</p>
     *
     */
    public function closeDevTools():void {
        if (safetyCheck())
            ctx.call("closeDevTools");
    }

    /**
     *
     * @return whether we have inited the webview
     *
     */
    public function get isInited():Boolean {
        return _isInited;
    }

    public function focus():void {
        if (safetyCheck())
            ctx.call("focus");
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
        if (code == null && scriptUrl == null) {
            throw new ArgumentError("code and scriptUrl cannot be null");
        }
        var theRet:* = ctx.call("injectScript", code, scriptUrl, startLine);
        if (theRet is ANEError) {
            throw theRet as ANEError;
        }
    }

    /**
     *
     * <p>prints the webView.</p>
     * <p><strong>Windows only.</strong></p>
     *
     */
    public function print():void {
        ctx.call("print");
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
        if (safetyCheck()) {
            return ctx.call("capture", x, y, width, height) as BitmapData;
        }
        return null;
    }

    /**
     *
     * @param value
     *
     */
    public function set visible(value:Boolean):void {
        if (_visible == value) return;
        _visible = value;
        if (safetyCheck()) {
            var theRet:* = ctx.call("setVisible", value);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }
    }

    /**
     *
     * @return whether the webView is visible
     *
     */
    public function get visible():Boolean {
        return _visible;
    }

    public function get viewPort():Rectangle {
        return _viewPort;
    }

    /**
     *
     * @param value
     * <p>Sets the viewPort of the webView.</p>
     *
     */
    public function set viewPort(value:Rectangle):void {
        if (viewPort == null) {
            throw new ArgumentError("viewPort cannot be null");
        }
        _viewPort = value;
        if (safetyCheck()) {
            var theRet:* = ctx.call("setViewPort", _viewPort);
            if (theRet is ANEError) {
                throw theRet as ANEError;
            }
        }

    }
}
}
