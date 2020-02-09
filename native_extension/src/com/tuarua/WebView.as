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
import com.tuarua.webview.BackForwardList;
import com.tuarua.webview.Settings;
import com.tuarua.webview.TabDetails;

import flash.desktop.NativeApplication;
import flash.display.NativeWindowDisplayState;
import flash.display.Stage;
import flash.events.EventDispatcher;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.external.ExtensionContext;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.net.URLRequest;

public class WebView extends EventDispatcher {
    private static const NAME:String = "WebViewANE";
    private static var _isInited:Boolean = false;
    private var _viewPort:Rectangle;
    private static const AS_CALLBACK_PREFIX:String = "TRWV.as.";
    private var _visible:Boolean;
    private var _settings:Settings;
    private static var _shared:WebView;

    /** @private */
    public function WebView() {
        if (_shared) {
            throw new Error(WebViewANEContext.NAME + " is a singleton, use .shared()");
        }
        //noinspection JSUnusedLocalSymbols
        var tmp:ExtensionContext = WebViewANEContext.context;
        _shared = this;
    }

    public static function shared():WebView {
        if (!_shared) new WebView();
        return _shared;
    }

    /**
     *
     * @param stage
     * @param viewPort
     * @param initialUrl Url to load when the view loads
     * @param settings
     * @param scaleFactor iOS, Android only
     * @param backgroundColor value of the view's background color in ARGB format.*
     * <p>Initialises the webView. N.B. The webView is set to visible = false initially.</p>
     */
    public function init(stage:Stage, viewPort:Rectangle, initialUrl:URLRequest = null,
                         settings:Settings = null, scaleFactor:Number = 1.0,
                         backgroundColor:uint = 0xFFFFFFFF):void {
        if (viewPort == null) {
            throw new ArgumentError("viewPort cannot be null");
        }
        WebViewANEContext.stage = stage;
        _viewPort = viewPort;

        if (os.isOSX) {
            NativeApplication.nativeApplication.activeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,
                    onWindowMiniMaxi, false, 1000);
        }
        stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEvent, false, 1000);

        _settings = settings;
        if (_settings == null) {
            _settings = new Settings();
        }

        var ret:* = WebViewANEContext.context.call("init", initialUrl, _viewPort, _settings, scaleFactor, backgroundColor);
        if (ret is ANEError) throw ret as ANEError;

        if ((os.isWindows || os.isOSX)) {
            if (this.hasEventListener(KeyboardEvent.KEY_UP)) {
                WebViewANEContext.context.call("addEventListener", KeyboardEvent.KEY_UP);
            }
            if (this.hasEventListener(KeyboardEvent.KEY_DOWN)) {
                WebViewANEContext.context.call("addEventListener", KeyboardEvent.KEY_DOWN);
            }
        }

        _isInited = true;
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false,
                                              priority:int = 0, useWeakReference:Boolean = false):void {
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
        if (_isInited && (KeyboardEvent.KEY_UP == type || KeyboardEvent.KEY_DOWN == type) && (os.isWindows || os.isOSX)) {
            if (this.hasEventListener(type)) {
                WebViewANEContext.context.call("addEventListener", type);
            }
        }
    }

    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        if (_isInited && (KeyboardEvent.KEY_UP == type || KeyboardEvent.KEY_DOWN == type) && (os.isWindows || os.isOSX)) {
            if (this.hasEventListener(type)) {
                WebViewANEContext.context.call("removeEventListener", type);
            }
        }
        super.removeEventListener(type, listener, useCapture);
    }

    /**
     *
     * @param functionName name of the function as called from Javascript
     * @param closure Actionscript function to call when functionName is called from Javascript
     *
     * Adds a callback in the webView. These should be added before .init() is called.
     *
     */
    public function addCallback(functionName:String, closure:Function):void {
        if (functionName && closure != null) {
            WebViewANEContext.jsCallBacks[functionName] = closure;
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
            WebViewANEContext.jsCallBacks[functionName] = null;
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
     * <listing version="3.0">
     * // Logs to the console. No result expected.
     * webView.callJavascriptFunction("as_to_js",asToJsCallback,1,"a",77);
     *
     * public function asToJsCallback(jsResult:JavascriptResult):void {
     *    trace("asToJsCallback");
     *    trace("jsResult.error", jsResult.error);
     *    trace("jsResult.result", jsResult.result);
     *    trace("jsResult.message", jsResult.message);
     *    trace("jsResult.success", jsResult.success);
     *    var testObject:* = jsResult.result;
     *    trace(testObject);
     * }
     * </listing>

     * @example
     * <listing version="3.0">
     * // Calls Javascript function passing 3 args. Javascript function returns an
     * // object which is automatically mapped to an
     * // Actionscript Object
     * webView.callJavascriptFunction("console.log",null,"hello console. The is AIR");
     *
     * // function in HTML page
     * function as_to_js(numberA, stringA, numberB, obj) {
     * var person = {
     *     name: "Jim Cowart",
     *     response: {
     *         name: "Chattanooga",
     *            population: 167674
     *        }
     *    };
     *    return person;
     * }
     * </listing>
     */
    public function callJavascriptFunction(functionName:String, closure:Function = null, ...args):void {
        if (functionName == null) {
            throw new ArgumentError("functionName cannot be null");
        }
        if (!safetyCheck()) return;
        var ret:*;
        var finalArray:Array = [];
        for each (var arg:* in args) {
            finalArray.push(JSON.stringify(arg));
        }
        var js:String = functionName + "(" + finalArray.toString() + ");";
        if (closure != null) {
            WebViewANEContext.asCallBacks[AS_CALLBACK_PREFIX + functionName] = closure;
            ret = WebViewANEContext.context.call("callJavascriptFunction", js, AS_CALLBACK_PREFIX + functionName);
        } else {
            ret = WebViewANEContext.context.call("callJavascriptFunction", js, null);
        }
        if (ret is ANEError) throw ret as ANEError;
    }

    //to insert script or run some js, no closure fire and forget
    /**
     *
     * @param code Javascript string to evaluate.
     * @param closure Actionscript function to call when the Javascript string is evaluated. If null then no
     * actionscript function is called, aka a 'fire and forget' call.
     *
     * @example
     * <listing version="3.0">
     * // Set the body background to yellow. No result expected
     * webView.evaluateJavascript('document.getElementsByTagName("body")[0].style.backgroundColor = "yellow";');
     * </listing>
     * @example
     * <listing version="3.0">
     * // Retrieve contents of div. Result is returned to Actionscript function 'onJsEvaluated'
     * webView.evaluateJavascript("document.getElementById('output').innerHTML;", onJsEvaluated)
     * private function onJsEvaluated(jsResult:JavascriptResult):void {
     *    trace("innerHTML of div is:", jsResult.result);
     * }
     * </listing>
     *
     */
    public function evaluateJavascript(code:String, closure:Function = null):void {
        if (code == null) {
            throw new ArgumentError("code cannot be null");
        }
        if (!safetyCheck()) return;
        var ret:*;
        if (closure != null) {
            var guid:String = GUID.create();
            WebViewANEContext.asCallBacks[AS_CALLBACK_PREFIX + guid] = closure;
            ret = WebViewANEContext.context.call("evaluateJavaScript", code, AS_CALLBACK_PREFIX + guid);
        } else {
            ret = WebViewANEContext.context.call("evaluateJavaScript", code, null);
        }
        if (ret is ANEError) {
            throw ret as ANEError;
        }
    }


    /** @private */
    private function onWindowMiniMaxi(event:NativeWindowDisplayStateEvent):void {
        /*
         !! Needed for OSX, restores webView when we restore from minimized state
         */
        if (event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED) {
            visible = false;
            visible = true;
        }
    }

    private function onFullScreenEvent(event:FullScreenEvent):void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("onFullScreen", event.fullScreen);
    }

    /**
     * @param url
     */
    public function load(url:URLRequest):void {
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("load", url);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     *
     * @param html HTML provided as a string
     * @param baseUrl url which will display as the address
     *
     * Loads a HTML string into the webView.
     *
     */
    public function loadHTMLString(html:String, baseUrl:URLRequest = null):void {
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("loadHTMLString", html, baseUrl);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     *
     * @param url full path to the file on the local file system
     * @param allowingReadAccessTo path to the root of the document
     *
     * Loads a file from the local file system into the webView.
     *
     */
    public function loadFileURL(url:String, allowingReadAccessTo:String):void {
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("loadFileURL", url, allowingReadAccessTo);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     * Reloads the current page.
     */
    public function reload():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("reload");
    }

    /**
     * Stops loading the current page.
     */
    public function stopLoading():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("stopLoading");
    }

    /**
     * Navigates back.
     */
    public function goBack():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("goBack");
    }

    /**
     * Navigates forward.
     */
    public function goForward():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("goForward");
    }

    /**
     *
     * @param offset Navigate forward (eg +1) or back (eg -1)
     *
     */
    public function go(offset:int = 1):void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("go", offset);
    }

    /**
     *
     * @return
     * <p><b>Ignored on Windows and Android.</b></p>
     */
    public function backForwardList():BackForwardList {
        if (!safetyCheck()) return new BackForwardList();
        return WebViewANEContext.context.call("backForwardList") as BackForwardList;
    }

    /**
     * Clears any persistent requestHeaders added to URLRequest
     */
    public function clearRequestHeaders():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("clearRequestHeaders");
    }

    /**
     * Forces a reload of the page (i.e. ctrl F5)
     */
    public function reloadFromOrigin():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("reloadFromOrigin");
    }

    /**
     * Clears the browser cache. Available on iOS, OSX, Android only.
     * <p><b>Ignored on Windows.</b></p>
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
                trace("[" + NAME + "] You cannot clear the cache on Windows while CEF is running. This is a known " + "limitation. You can only call this method after .dispose() is called");
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
                trace("[" + NAME + "] unable to delete cache files");
            }
            return;
        }
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("clearCache");
    }

    /**
     *
     * @return Whether the page allows magnification functionality
     * <b>Ignored on iOS.</b>
     */
    public function allowsMagnification():Boolean {
        if (!safetyCheck()) return false;
        return WebViewANEContext.context.call("allowsMagnification") as Boolean;
    }

    /**
     * Zooms in
     *
     */
    public function zoomIn():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("zoomIn");
    }

    /** Zooms out*/
    public function zoomOut():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("zoomOut");
    }

    /** Windows + OSX only */
    public function addTab(initialUrl:URLRequest = null):void {
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("addTab", initialUrl);
        if (ret is ANEError) throw ret as ANEError;
    }

    /** Windows + OSX only*/
    public function closeTab(index:int):void {
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("closeTab", index);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**Windows + OSX only*/
    public function set currentTab(value:int):void {
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("setCurrentTab", value);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**Windows + OSX only*/
    public function get currentTab():int {
        if (!safetyCheck()) return 0;
        return int(WebViewANEContext.context.call("getCurrentTab"));
    }

    public function get tabDetails():Vector.<TabDetails> {
        if (!safetyCheck()) return new Vector.<TabDetails>();
        var ret:* = WebViewANEContext.context.call("getTabDetails");
        if (ret is ANEError) throw ret as ANEError;
        return Vector.<TabDetails>(ret);
    }

    /**
     * Shows the Chromium dev tools on Windows
     * <p>Enables Inspect Element on right click on OSX</p>
     * <p>On Android use Chrome on connected computer and navigate to chrome://inspect</p>
     */
    public function showDevTools():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("showDevTools");
    }

    /**
     * Close the Chromium dev tools
     * <p>Disables Inspect Element on right click on OSX</p>
     * <p>On Android disconnects from chrome://inspect</p>
     */
    public function closeDevTools():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("closeDevTools");
    }

    public function focus():void {
        if (!safetyCheck()) return;
        WebViewANEContext.context.call("focus");
    }

    /**
     *
     * @param code Javascript to inject, if any.
     * @param scriptUrl is the URL where the script in question can be found, if any. Windows only
     * @param startLine is the base line number to use for error reporting. Windows only
     *
     * <p>Specify either code or scriptUrl. These are injected into the main Frame when it is loaded. Call before
     * load() method</p>
     * <p><b>Ignored on Android.</b></p>
     */
    public function injectScript(code:String = null, scriptUrl:String = null, startLine:uint = 0):void {
        if (code == null && scriptUrl == null) {
            throw new ArgumentError("code and scriptUrl cannot be null");
        }
        var ret:* = WebViewANEContext.context.call("injectScript", code, scriptUrl, startLine);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     * Prints the webView.
     * <p><b>Windows only.</b></p>
     */
    public function print():void {
        WebViewANEContext.context.call("print");
    }

    /**
     * @param savePath path to save the pdf to.
     *
     * Prints the webView to a pdf.
     * <p><b>Windows only.</b></p>
     */
    public function printToPdf(savePath:String):void {
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("printToPdf", savePath);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     * Deletes all cookies
     */
    public function deleteCookies():void {
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("deleteCookies");
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     * Captures the webView to BitmapData.
     *
     * @param onComplete function(result:BitmapData)
     * @param cropTo optionally crops to the supplied Rectangle
     */
    public function capture(onComplete:Function, cropTo:Rectangle = null):void {
        if (!safetyCheck()) return;
        WebViewANEContext.onCaptureComplete = onComplete;
        var ret:* = WebViewANEContext.context.call("capture", cropTo);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     * @param value
     */
    public function set visible(value:Boolean):void {
        if (_visible == value) return;
        _visible = value;
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("setVisible", value);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     * @return whether the webView is visible
     */
    public function get visible():Boolean {
        return _visible;
    }

    public function get viewPort():Rectangle {
        return _viewPort;
    }

    /**
     * @param value
     * Sets the viewPort of the webView.
     */
    public function set viewPort(value:Rectangle):void {
        if (viewPort == null) {
            throw new ArgumentError("viewPort cannot be null");
        }
        _viewPort = value;
        if (!safetyCheck()) return;
        var ret:* = WebViewANEContext.context.call("setViewPort", _viewPort);
        if (ret is ANEError) throw ret as ANEError;
    }

    /**
     * This cleans up the webview and all related processes.
     * <p><b>It is important to call this when the app is exiting.</b></p>
     * @example
     * <listing version="3.0">
     * NativeApplication.nativeApplication.addEventListener(flash.events.Event.EXITING, onExiting);
     * private function onExiting(event:Event):void {
     *    WebView.dispose();
     * }</listing>
     *
     */
    /** Disposes the ANE */
    public static function dispose():void {
        if (WebViewANEContext.context) {
            WebViewANEContext.dispose();
        }
        _isInited = false;
    }

    /** @private */
    private function safetyCheck():Boolean {
        if (!_isInited) {
            trace("You need to init first");
            return false;
        }
        return true;
    }

}
}
